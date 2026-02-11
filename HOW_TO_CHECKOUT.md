# 如何使用 AI 集成分支 / How to Use the AI Integration Branch

## 问题：为什么签出或应用不了？/ Issue: Why can't I checkout or apply?

这个 PR 的更改位于 `copilot/embed-openai-expert-model` 分支中。以下是几种使用这些更改的方法：

The changes in this PR are in the `copilot/embed-openai-expert-model` branch. Here are several ways to use these changes:

---

## 方法 1: 直接签出分支 / Method 1: Direct Checkout

这是最简单的方法 / This is the simplest method:

```bash
# 1. 克隆仓库（如果还没有）/ Clone the repository (if you haven't already)
git clone https://github.com/Hb-zzz-momo/monitoring_system.git
cd monitoring_system

# 2. 签出 AI 集成分支 / Checkout the AI integration branch
git checkout copilot/embed-openai-expert-model

# 3. 确认您在正确的分支上 / Confirm you're on the correct branch
git branch
# 应该显示 / Should show: * copilot/embed-openai-expert-model

# 4. 查看文件 / View the files
ls -la
```

---

## 方法 2: 合并到您的分支 / Method 2: Merge into Your Branch

如果您想将 AI 功能合并到另一个分支（如 main）：

If you want to merge the AI features into another branch (like main):

```bash
# 1. 签出目标分支 / Checkout your target branch
git checkout main

# 2. 合并 AI 分支 / Merge the AI branch
git merge copilot/embed-openai-expert-model

# 3. 解决任何冲突（如果有）/ Resolve any conflicts (if any)

# 4. 完成合并 / Complete the merge
git commit
```

---

## 方法 3: 创建新分支测试 / Method 3: Create New Branch for Testing

如果您想在不影响现有分支的情况下测试：

If you want to test without affecting existing branches:

```bash
# 1. 从 AI 分支创建新的测试分支 / Create a new test branch from AI branch
git checkout -b test-ai-features copilot/embed-openai-expert-model

# 2. 现在您可以安全地测试 / Now you can safely test
# 不会影响其他分支 / Without affecting other branches
```

---

## 方法 4: 查看具体文件 / Method 4: View Specific Files

如果您只想查看某些文件而不签出整个分支：

If you only want to view certain files without checking out the entire branch:

```bash
# 查看特定文件 / View specific file
git show copilot/embed-openai-expert-model:lib/main.dart

# 或复制特定文件到当前分支 / Or copy specific file to current branch
git checkout copilot/embed-openai-expert-model -- lib/services/ai_service.dart
```

---

## 运行应用 / Running the Application

签出分支后，运行应用：

After checking out the branch, run the application:

```bash
# 1. 安装依赖 / Install dependencies
flutter pub get

# 2. 运行应用 / Run the application
flutter run

# 或者，如果 Flutter 未安装，只需查看代码
# Or, if Flutter is not installed, just view the code
```

---

## 常见问题 / Common Issues

### 问题 1: "error: pathspec 'copilot/embed-openai-expert-model' did not match"

**原因 / Cause**: 远程分支未获取

**解决方案 / Solution**:
```bash
git fetch origin
git checkout copilot/embed-openai-expert-model
```

### 问题 2: "Please commit your changes or stash them before you switch branches"

**原因 / Cause**: 您有未提交的更改

**解决方案 / Solution**:
```bash
# 选项 A: 提交更改 / Option A: Commit changes
git add .
git commit -m "保存当前更改"

# 选项 B: 暂存更改 / Option B: Stash changes
git stash
git checkout copilot/embed-openai-expert-model
# 之后恢复 / Later restore with: git stash pop
```

### 问题 3: "fatal: A branch named 'copilot/embed-openai-expert-model' already exists"

**原因 / Cause**: 本地已存在该分支

**解决方案 / Solution**:
```bash
# 直接切换到该分支 / Just switch to that branch
git checkout copilot/embed-openai-expert-model

# 或更新到最新版本 / Or update to latest version
git checkout copilot/embed-openai-expert-model
git pull origin copilot/embed-openai-expert-model
```

---

## 查看更改内容 / View Changes

查看此分支相对于 main 的所有更改：

View all changes in this branch compared to main:

```bash
# 查看文件列表 / View list of files changed
git diff main..copilot/embed-openai-expert-model --name-only

# 查看具体更改 / View specific changes
git diff main..copilot/embed-openai-expert-model

# 查看提交历史 / View commit history
git log main..copilot/embed-openai-expert-model --oneline
```

---

## 文件结构 / File Structure

AI 集成的主要文件位于 / Main files for AI integration are in:

```
monitoring_system/
├── lib/
│   ├── main.dart                     # 已更新：添加 AI Tab
│   ├── services/
│   │   ├── ai_service.dart          # 新增：AI 服务
│   │   ├── ai_chat_provider.dart    # 新增：状态管理
│   │   └── ai_config.dart           # 新增：配置
│   ├── screens/
│   │   └── ai_assistant_screen.dart # 新增：AI 界面
│   └── widgets/
│       ├── ai_alarm_analysis.dart   # 新增：告警分析组件
│       └── ai_work_order_suggestion.dart # 新增：工单建议组件
└── 文档 / Documentation
    ├── README.md                     # 已更新
    ├── AI_INTEGRATION.md             # 新增
    ├── QUICK_START.md                # 新增
    └── ...
```

---

## 推荐步骤 / Recommended Steps

**最简单的方法 / Easiest Method**:

```bash
# 1. 确保您在项目目录中 / Make sure you're in the project directory
cd monitoring_system

# 2. 获取最新的远程分支 / Fetch latest remote branches
git fetch origin

# 3. 签出 AI 分支 / Checkout the AI branch
git checkout copilot/embed-openai-expert-model

# 4. 确认成功 / Confirm success
git status
# 应显示 / Should show: On branch copilot/embed-openai-expert-model

# 5. 查看文档了解如何使用 / Read documentation to learn how to use
cat QUICK_START.md
```

---

## 需要帮助？/ Need Help?

如果以上方法都不行，请提供：

If none of the above works, please provide:

1. 您尝试的具体命令 / The exact command you tried
2. 完整的错误消息 / The complete error message
3. `git status` 的输出 / Output of `git status`
4. `git branch -a` 的输出 / Output of `git branch -a`

这样我可以提供更具体的帮助。

Then I can provide more specific help.

---

## 快速测试 / Quick Test

签出分支后，验证 AI 功能：

After checking out the branch, verify AI functionality:

```bash
# 查看 AI 相关文件是否存在 / Check if AI files exist
ls -la lib/services/ai_service.dart
ls -la lib/screens/ai_assistant_screen.dart

# 查看文档 / View documentation
ls -la *.md
```

如果这些文件存在，说明签出成功！

If these files exist, the checkout was successful!
