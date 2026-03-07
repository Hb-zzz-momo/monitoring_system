from __future__ import annotations

import os
import subprocess
import time
from pathlib import Path
from urllib import error, request

from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException

import database as db
from models import (
    ManualTrainingSampleCreate,
    TrainingCollectResponse,
    TrainingJob,
    TrainingJobStartResponse,
    TrainingSample,
)
from security import get_current_user, require_admin

router = APIRouter(prefix="/ai/training", tags=["ai-training"])

_REPO_ROOT = Path(__file__).resolve().parents[2]
_DEFAULT_OUTPUT = _REPO_ROOT / "local_ai" / "data" / "train.jsonl"
_DEFAULT_DEPLOY_BAT = _REPO_ROOT / "serve_trained_model.bat"
_DEFAULT_HEALTH_URL = "http://127.0.0.1:8008/v1/models"


def _run_shell_command(command: str) -> tuple[int, list[str]]:
    process = subprocess.Popen(
        command,
        cwd=str(_REPO_ROOT),
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    output_lines: list[str] = []
    assert process.stdout is not None
    for line in process.stdout:
        output_lines.append(line.strip())
    return_code = process.wait()
    return return_code, output_lines


def _wait_health_ready(url: str, timeout_seconds: int = 120, interval_seconds: int = 2) -> tuple[bool, str]:
    deadline = time.time() + max(1, timeout_seconds)
    last_error = ""
    while time.time() < deadline:
        try:
            with request.urlopen(url, timeout=8) as resp:
                if 200 <= resp.status < 300:
                    return True, f"健康检查通过：{url}"
                last_error = f"HTTP {resp.status}"
        except error.HTTPError as exc:
            last_error = f"HTTPError {exc.code}"
        except Exception as exc:
            last_error = str(exc)
        time.sleep(max(1, interval_seconds))
    return False, f"健康检查失败：{url}，最后错误：{last_error or 'unknown'}"


def _run_local_training(job_id: str, train_command: str, deploy_command: str, health_url: str) -> None:
    try:
        db.update_training_job(
            job_id,
            status="running",
            message="训练中：正在执行本地训练命令",
        )
        train_code, train_logs = _run_shell_command(train_command)

        sample_count = len(db.list_training_samples(limit=2000))
        if train_code != 0:
            db.update_training_job(
                job_id,
                status="failed",
                processed_samples=sample_count,
                message="\n".join(train_logs[-20:]) or f"训练失败，退出码 {train_code}",
            )
            return

        db.update_training_job(
            job_id,
            status="deploying",
            processed_samples=sample_count,
            message="训练完成：正在部署模型服务",
        )

        if deploy_command:
            deploy_code, deploy_logs = _run_shell_command(deploy_command)
            if deploy_code != 0:
                db.update_training_job(
                    job_id,
                    status="failed",
                    processed_samples=sample_count,
                    message="\n".join(deploy_logs[-20:]) or f"部署失败，退出码 {deploy_code}",
                )
                return

            if health_url:
                ok, health_message = _wait_health_ready(health_url)
                if not ok:
                    db.update_training_job(
                        job_id,
                        status="failed",
                        processed_samples=sample_count,
                        message=health_message,
                    )
                    return

                db.update_training_job(
                    job_id,
                    status="completed",
                    processed_samples=sample_count,
                    model_name="expert-local",
                    message=f"本地训练完成，模型已部署并可用。{health_message}",
                )
                return

        db.update_training_job(
            job_id,
            status="completed",
            processed_samples=sample_count,
            model_name="expert-local",
            message="本地训练完成，未执行健康检查。",
        )
    except Exception as exc:
        db.update_training_job(job_id, status="failed", message=f"训练/部署失败: {exc}")


@router.post("/samples/collect/device", response_model=TrainingCollectResponse)
def collect_device_samples(_admin_user: dict = Depends(require_admin)):
    added = db.collect_training_samples_from_devices()
    return TrainingCollectResponse(success=True, added=added)


@router.post("/samples/collect/alarm", response_model=TrainingCollectResponse)
def collect_alarm_samples(_admin_user: dict = Depends(require_admin)):
    added = db.collect_training_samples_from_alarms()
    return TrainingCollectResponse(success=True, added=added)


@router.post("/samples", response_model=TrainingSample)
def create_manual_sample(
    body: ManualTrainingSampleCreate,
    _admin_user: dict = Depends(require_admin),
):
    return db.add_training_sample(
        source=body.source,
        input_text=body.input,
        expected_output=body.expectedOutput,
    )


@router.get("/samples", response_model=list[TrainingSample])
def list_samples(limit: int = 200, _current_user: dict = Depends(get_current_user)):
    return db.list_training_samples(limit=limit)


@router.delete("/samples/{sample_id}")
def delete_sample(sample_id: int, _admin_user: dict = Depends(require_admin)):
    deleted = db.delete_training_sample(sample_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="训练样本不存在")
    return {"success": True}


@router.post("/export")
def export_dataset(_admin_user: dict = Depends(require_admin)):
    count = db.export_training_jsonl(_DEFAULT_OUTPUT)
    return {
        "success": True,
        "samples": count,
        "output": str(_DEFAULT_OUTPUT),
    }


@router.post("/jobs/start", response_model=TrainingJobStartResponse)
def start_training(
    background_tasks: BackgroundTasks,
    _admin_user: dict = Depends(require_admin),
):
    sample_count = len(db.list_training_samples(limit=2000))
    if sample_count == 0:
        db.collect_training_samples_from_devices()
        db.collect_training_samples_from_alarms()
        sample_count = len(db.list_training_samples(limit=2000))

    db.export_training_jsonl(_DEFAULT_OUTPUT)

    train_command = os.getenv("LOCAL_TRAIN_COMMAND", "").strip()
    if not train_command:
        train_bat = _REPO_ROOT / "train_local_model.bat"
        if train_bat.exists():
            train_command = f'"{train_bat}"'

    deploy_command = os.getenv("LOCAL_DEPLOY_COMMAND", "").strip()
    if not deploy_command and _DEFAULT_DEPLOY_BAT.exists():
        deploy_command = f'"{_DEFAULT_DEPLOY_BAT}"'

    health_url = os.getenv("LOCAL_DEPLOY_HEALTH_URL", _DEFAULT_HEALTH_URL).strip()

    job = db.create_training_job(total_samples=sample_count, message="训练任务已启动")

    if train_command:
        background_tasks.add_task(_run_local_training, job.id, train_command, deploy_command, health_url)
    else:
        db.update_training_job(
            job.id,
            status="completed",
            processed_samples=sample_count,
            model_name="expert-local",
            message="未配置 LOCAL_TRAIN_COMMAND，已完成数据导出，可手动执行 train_local_model.bat",
        )
        job = db.get_training_job(job.id) or job

    return TrainingJobStartResponse(success=True, job=job)


@router.get("/jobs", response_model=list[TrainingJob])
def list_jobs(limit: int = 20, _current_user: dict = Depends(get_current_user)):
    return db.list_training_jobs(limit=limit)
