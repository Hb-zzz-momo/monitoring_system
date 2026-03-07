from __future__ import annotations

from fastapi import WebSocket


class RealtimeHub:
    def __init__(self) -> None:
        self._connections: dict[WebSocket, dict] = {}

    async def connect(self, websocket: WebSocket, subscription: dict | None = None) -> None:
        await websocket.accept()
        self._connections[websocket] = subscription or {}

    def update_subscription(self, websocket: WebSocket, subscription: dict) -> None:
        if websocket in self._connections:
            self._connections[websocket] = subscription

    def disconnect(self, websocket: WebSocket) -> None:
        self._connections.pop(websocket, None)

    @staticmethod
    def _matches(subscription: dict, *, device_id: str | None, channel: str | None) -> bool:
        sub_device_id = subscription.get("device_id")
        if sub_device_id and device_id and sub_device_id != device_id:
            return False

        channels = subscription.get("channels")
        if channels and channel and channel not in channels:
            return False
        return True

    async def broadcast(self, payload: dict, *, device_id: str | None = None, channel: str | None = None) -> None:
        dead: list[WebSocket] = []
        for ws, sub in self._connections.items():
            if not self._matches(sub, device_id=device_id, channel=channel):
                continue
            try:
                await ws.send_json(payload)
            except Exception:
                dead.append(ws)
        for ws in dead:
            self.disconnect(ws)


realtime_hub = RealtimeHub()
