# Git Workflow Guide

## Table of Contents
1. [Repository Setup](#repository-setup)
2. [Branching Strategy](#branching-strategy)
3. [Commit Standards](#commit-standards)
4. [Pull Request Workflow](#pull-request-workflow)
5. [Commit Timeline Example](#commit-timeline-example)

---

## Repository Setup

### 1. Initialize Git Repository

```bash
# Navigate to your project directory
cd "G:\PROJECTS\CSE489 LAB MID"

# Initialize Git repository
git init

# Verify initialization
git status
```

### 2. Create .gitignore for Flutter

Create a `.gitignore` file in the root directory with the following content:

```gitignore
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# The .vscode folder contains launch configuration and tasks you configure in
# VS Code which you may wish to be included in version control, so this line
# is commented out by default.
.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release

# iOS/XCode related
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# Coverage
coverage/

# Exceptions to above rules.
!**/ios/**/default.mode1v3
!**/ios/**/default.mode2v3
!**/ios/**/default.pbxuser
!**/ios/**/default.perspectivev3

# Environment files
.env
.env.*
!.env.example

# Firebase
google-services.json
GoogleService-Info.plist
firebase_options.dart

# Local database files
*.db
*.sqlite
*.sqlite3
```

### 3. Connect to GitHub/GitLab

#### For GitHub:

```bash
# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Verify remote connection
git remote -v
```

#### For GitLab:

```bash
# Add your GitLab repository as remote
git remote add origin https://gitlab.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Verify remote connection
git remote -v
```

#### Initial Commit and Push:

```bash
# Stage all files
git add .

# Create initial commit
git commit -m "chore: initial project setup"

# Push to remote repository
git push -u origin main
```

---

## Branching Strategy

### Branch Structure

```
main (or master)
├── development
    ├── feature/map-view
    ├── feature/list-view
    ├── feature/form
    ├── feature/offline-caching
    └── feature/authentication
```

### Main Branches

#### 1. **main/master** Branch
- Production-ready code
- Only merge from `development` after thorough testing
- Protected branch (no direct commits)
- All code must pass through pull requests

#### 2. **development** Branch
- Integration branch for features
- Testing ground before merging to main
- Should always be in a working state

### Feature Branches

Create feature branches for each major functionality:

```bash
# Create and switch to development branch
git checkout -b development

# Create feature branches from development
git checkout development
git checkout -b feature/map-view

git checkout development
git checkout -b feature/list-view

git checkout development
git checkout -b feature/form

git checkout development
git checkout -b feature/offline-caching

git checkout development
git checkout -b feature/authentication
```

### Branch Naming Conventions

Follow these naming patterns:

- **Feature branches**: `feature/descriptive-name`
  - `feature/map-view`
  - `feature/list-view`
  - `feature/form-validation`
  - `feature/offline-caching`
  - `feature/authentication`

- **Bug fixes**: `fix/descriptive-name`
  - `fix/marker-positioning`
  - `fix/image-upload-error`
  - `fix/form-validation-bug`

- **Refactoring**: `refactor/descriptive-name`
  - `refactor/landmark-service`
  - `refactor/state-management`

- **Documentation**: `docs/descriptive-name`
  - `docs/api-documentation`
  - `docs/setup-instructions`

- **Performance improvements**: `perf/descriptive-name`
  - `perf/optimize-map-rendering`

- **Testing**: `test/descriptive-name`
  - `test/unit-tests`
  - `test/widget-tests`

### Branch Workflow Example

```bash
# 1. Start working on map view feature
git checkout development
git pull origin development
git checkout -b feature/map-view

# 2. Make changes and commit
git add .
git commit -m "feat: add Google Maps integration"

# 3. Push feature branch to remote
git push -u origin feature/map-view

# 4. After PR is approved, merge to development
git checkout development
git merge feature/map-view

# 5. Delete feature branch after merge
git branch -d feature/map-view
git push origin --delete feature/map-view

# 6. When development is stable, merge to main
git checkout main
git merge development
git push origin main
```

---

## Commit Standards

### Conventional Commits Format

Follow the Conventional Commits specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Commit Types

- **feat**: A new feature
- **fix**: A bug fix
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (formatting, etc.)
- **test**: Adding missing tests or correcting existing tests
- **perf**: A code change that improves performance
- **chore**: Changes to the build process or auxiliary tools
- **build**: Changes that affect the build system or external dependencies
- **ci**: Changes to CI configuration files and scripts

### Commit Message Examples

#### Feature Commits

```bash
git commit -m "feat: add map view with custom markers"

git commit -m "feat: implement Google Maps integration with custom landmark markers"

git commit -m "feat: add list view with swipe-to-delete functionality"

git commit -m "feat: create add landmark form with validation"

git commit -m "feat: implement image picker for landmark photos"

git commit -m "feat: add bottom sheet for landmark details"

git commit -m "feat: implement offline caching with SQLite"

git commit -m "feat: add user authentication with Firebase"

git commit -m "feat: create edit landmark functionality"
```

#### Fix Commits

```bash
git commit -m "fix: correct image upload issue in add landmark form"

git commit -m "fix: resolve marker positioning error on map"

git commit -m "fix: handle null values in landmark model"

git commit -m "fix: correct form validation for empty fields"

git commit -m "fix: resolve bottom sheet overflow issue"
```

#### Refactor Commits

```bash
git commit -m "refactor: improve landmark service structure"

git commit -m "refactor: extract map widget into separate component"

git commit -m "refactor: reorganize project folder structure"

git commit -m "refactor: optimize state management with Provider"
```

#### Documentation Commits

```bash
git commit -m "docs: update README with setup instructions"

git commit -m "docs: add inline comments to landmark model"

git commit -m "docs: create API documentation for services"

git commit -m "docs: add Git workflow guide"
```

#### Style Commits

```bash
git commit -m "style: format code according to Flutter standards"

git commit -m "style: apply consistent naming conventions"

git commit -m "style: organize imports alphabetically"
```

#### Test Commits

```bash
git commit -m "test: add unit tests for landmark model"

git commit -m "test: add widget tests for map view"

git commit -m "test: add integration tests for form submission"
```

#### Performance Commits

```bash
git commit -m "perf: optimize map rendering performance"

git commit -m "perf: reduce memory usage in image loading"
```

#### Chore Commits

```bash
git commit -m "chore: update dependencies to latest versions"

git commit -m "chore: configure Flutter environment"

git commit -m "chore: add .gitignore for Flutter project"
```

### Best Practices

1. **Use imperative mood**: "add feature" not "added feature"
2. **Keep subject line under 50 characters**
3. **Capitalize first letter of subject**
4. **No period at the end of subject line**
5. **Separate subject from body with blank line**
6. **Wrap body at 72 characters**
7. **Use body to explain what and why, not how**
8. **Reference issue numbers in footer**: `Closes #123`

### Minimum Commit Requirements

**At least 10 meaningful commits** are required for this project. Ensure commits are:
- Atomic (one logical change per commit)
- Descriptive (clear subject lines)
- Progressive (show development progress)
- Not trivial (avoid commits like "fix typo" unless necessary)

---

## Pull Request Workflow

### Creating Pull Requests

#### 1. Prepare Your Branch

```bash
# Ensure your branch is up to date
git checkout feature/map-view
git fetch origin
git rebase origin/development

# Push your changes
git push origin feature/map-view
```

#### 2. Create Pull Request on GitHub/GitLab

**On GitHub:**
- Navigate to your repository
- Click "Pull requests" → "New pull request"
- Select base: `development` and compare: `feature/map-view`
- Fill in the PR template (see below)

**On GitLab:**
- Navigate to your repository
- Click "Merge Requests" → "New merge request"
- Select source: `feature/map-view` and target: `development`
- Fill in the MR template

### Pull Request Description Template

```markdown
## Description
Brief description of what this PR accomplishes.

## Type of Change
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Refactoring
- [ ] Performance improvement

## Changes Made
- Added Google Maps integration
- Implemented custom marker functionality
- Created landmark model
- Added bottom sheet for landmark details

## Screenshots/Videos
[Add screenshots or demo videos if applicable]

## Testing
- [ ] Tested on Android
- [ ] Tested on iOS
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] All tests passing

## Checklist
- [ ] Code follows Flutter style guidelines
- [ ] Self-review completed
- [ ] Code is commented where necessary
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Changes generate no new errors
- [ ] Branch is up to date with base branch

## Related Issues
Closes #[issue number]

## Additional Notes
Any additional information that reviewers should know.
```

### Code Review Checklist

#### For Reviewers:

- [ ] **Code Quality**
  - Code is readable and maintainable
  - Follows Dart/Flutter best practices
  - No unnecessary code duplication
  - Functions are appropriately sized

- [ ] **Functionality**
  - Feature works as described
  - No breaking changes
  - Edge cases handled
  - Error handling implemented

- [ ] **Performance**
  - No memory leaks
  - Efficient algorithms used
  - No unnecessary rebuilds

- [ ] **Testing**
  - Adequate test coverage
  - Tests are meaningful
  - All tests pass

- [ ] **Documentation**
  - Code is well-commented
  - README updated if needed
  - API documentation complete

- [ ] **UI/UX**
  - UI is responsive
  - Follows design guidelines
  - Accessible

### Merging Strategy

#### Option 1: Merge Commit (Recommended for features)
```bash
git checkout development
git merge --no-ff feature/map-view
git push origin development
```

#### Option 2: Squash and Merge (For multiple small commits)
```bash
git checkout development
git merge --squash feature/map-view
git commit -m "feat: add complete map view feature"
git push origin development
```

#### Option 3: Rebase and Merge (For linear history)
```bash
git checkout feature/map-view
git rebase development
git checkout development
git merge feature/map-view
git push origin development
```

### Post-Merge Cleanup

```bash
# Delete local feature branch
git branch -d feature/map-view

# Delete remote feature branch
git push origin --delete feature/map-view

# Update local development branch
git checkout development
git pull origin development
```

---

## Commit Timeline Example

### Sample Commit History (Progressive Development)

Below is an example commit timeline showing how the project should develop progressively:

```bash
# Day 1: Project Setup
git commit -m "chore: initialize Flutter project with basic structure"
git commit -m "chore: add .gitignore for Flutter project"
git commit -m "docs: create README with project overview"

# Day 2: Map View Development
git commit -m "feat: add Google Maps dependency and configuration"
git commit -m "feat: implement basic map view screen"
git commit -m "feat: add custom marker functionality for landmarks"
git commit -m "feat: create landmark model with required fields"

# Day 3: Bottom Sheet and Details
git commit -m "feat: add bottom sheet for landmark details display"
git commit -m "style: improve bottom sheet UI with proper spacing"
git commit -m "fix: correct bottom sheet overflow issue on small screens"

# Day 4: List View Implementation
git commit -m "feat: create list view screen for landmarks"
git commit -m "feat: add swipe-to-delete functionality in list view"
git commit -m "feat: implement swipe-to-edit action"

# Day 5: Form Development
git commit -m "feat: create add landmark form with all fields"
git commit -m "feat: add image picker integration for landmark photos"
git commit -m "feat: implement form validation logic"
git commit -m "fix: handle image upload error cases"

# Day 6: Service Layer
git commit -m "refactor: create landmark service for data management"
git commit -m "feat: add edit landmark functionality"
git commit -m "feat: implement delete landmark with confirmation"

# Day 7: State Management
git commit -m "refactor: integrate Provider for state management"
git commit -m "perf: optimize map rendering with debouncing"

# Day 8: Error Handling
git commit -m "feat: add comprehensive error handling across app"
git commit -m "feat: implement user-friendly error messages"

# Day 9: Bonus Features (Optional)
git commit -m "feat: add SQLite integration for offline caching"
git commit -m "feat: implement Firebase authentication"
git commit -m "test: add unit tests for landmark model and service"

# Day 10: Polish and Documentation
git commit -m "style: format all code according to Flutter standards"
git commit -m "docs: add inline documentation to complex functions"
git commit -m "docs: update README with complete setup instructions"
git commit -m "docs: create Git workflow documentation"
git commit -m "chore: final cleanup and optimization"
```

### Detailed Timeline with Descriptions

| Day | Commits | Focus Area | Description |
|-----|---------|------------|-------------|
| 1 | 3 | Project Setup | Initialize project, configure environment, create basic documentation |
| 2 | 4 | Map View | Implement Google Maps integration, create landmark model, add markers |
| 3 | 3 | Details View | Add bottom sheet functionality, improve UI, fix layout issues |
| 4 | 3 | List View | Create list screen, implement swipe actions for edit/delete |
| 5 | 4 | Form | Build add/edit form, integrate image picker, add validation |
| 6 | 3 | Services | Create service layer for CRUD operations, refactor data management |
| 7 | 2 | Optimization | Implement state management, optimize performance |
| 8 | 2 | Error Handling | Add comprehensive error handling throughout the app |
| 9 | 3 | Bonus Features | Implement offline caching, authentication, write tests |
| 10 | 5 | Final Polish | Code formatting, documentation, final testing and cleanup |

### Best Practices for Commit Timeline

1. **Incremental Progress**: Each commit should represent a working state
2. **Logical Grouping**: Related changes should be in the same commit
3. **Frequent Commits**: Commit small, meaningful changes regularly
4. **Clear Messages**: Use descriptive commit messages that explain the "why"
5. **Test Before Commit**: Ensure code compiles and runs before committing
6. **Avoid Large Commits**: Break large features into smaller, manageable commits
7. **Document as You Go**: Include documentation commits alongside feature commits

---

## Quick Reference

### Common Git Commands

```bash
# Check status
git status

# View commit history
git log --oneline --graph --all

# Create and switch to new branch
git checkout -b feature/new-feature

# Stage changes
git add .
git add specific-file.dart

# Commit changes
git commit -m "feat: add new feature"

# Push to remote
git push origin feature/new-feature

# Pull latest changes
git pull origin development

# Merge branch
git merge feature/new-feature

# Delete branch
git branch -d feature/new-feature

# Stash changes
git stash
git stash pop

# View differences
git diff
git diff --staged

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1
```

### Troubleshooting

#### Resolve Merge Conflicts

```bash
# When merge conflict occurs
git status  # See conflicting files

# Edit conflicting files manually
# Look for <<<<<<< HEAD and >>>>>>> markers

# After resolving
git add .
git commit -m "fix: resolve merge conflicts"
```

#### Update Forked Repository

```bash
# Add upstream remote (original repository)
git remote add upstream https://github.com/ORIGINAL_OWNER/REPO.git

# Fetch upstream changes
git fetch upstream

# Merge upstream changes
git checkout main
git merge upstream/main
```

---

## Submission Checklist

Before submitting your project, ensure:

- [ ] At least 10 meaningful commits
- [ ] Commits follow conventional commit format
- [ ] All feature branches merged to development
- [ ] Development merged to main
- [ ] All remote branches up to date
- [ ] .gitignore properly configured
- [ ] README.md is complete
- [ ] Code is properly documented
- [ ] All tests passing
- [ ] No sensitive data in repository
- [ ] Repository is accessible to instructors

---

**Last Updated**: December 2025
**Course**: CSE489 - Mobile Application Development
**Project**: Flutter Landmark Management App
