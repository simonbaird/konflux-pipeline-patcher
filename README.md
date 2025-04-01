
# Konflux Pipeline Patcher

A command line tool to help add new tasks to existing Konflux pipelines.

## Installation

```bash
curl -sLO https://github.com/simonbaird/konflux-pipeline-patcher/raw/main/pipeline-patcher && chmod a+x ./pipeline-patcher
```

## Usage

```bash
# Show a list of known pipeline tasks
./pipeline-patcher list-tasks

# Show the latest trusted bundle ref for given pipeline task
./pipeline-patcher task-ref <task-name> <version>
./pipeline-patcher task-ref <task-name>:<version>
./pipeline-patcher task-ref <task-bundle-ref>

# Lookup tasks in the trusted task data and output all the known
# bundle digests and their related dates
./pipeline-patcher trusted-task-lookup [<task-name-or-substring>]

# Output a snippet of yaml suitable for adding a task to a Konflux pipeline
./pipeline-patcher task-yaml <task-name>

# Modify a single Konflux pipeline definition to add a new task
# Supports multiple comma-separated task names
# The <before-task-name> is used to specify where in the yaml file to add the new
# task. If unset, 'clamav-scan' and 'deprecated-image-check' will be tried.
./pipeline-patcher patch <path-to-pipeline-yaml> <new-task-name-or-names> [<before-task-name>]

# Modify all the Konflux pipelines in a git repo to add a new task
# Supports multiple comma-separated task names. (See above re <before-task-name>).
./pipeline-patcher add-tasks <path-to-git-repo> <new-task-name-or-names> [<before-task-name>]

# Update task bundle references in your pipeline definitions to the latest
# newest digests from the trusted task list. (Manually perform the kind of
# update usually done by MintMaker or Renovate.)
./pipeline-patcher bump-task-refs <path-to-git-repo>

# Show this help
./pipeline-patcher help
```

## Requirements

* bash
* curl
* awk
* sed
* jq
* git
* [oras](https://github.com/oras-project/oras/releases/latest)
* [yq](https://github.com/mikefarah/yq/releases/latest)
  ([mikefarah](https://github.com/mikefarah/yq/) not [PyPi](https://pypi.org/project/yq/))

## Status

It's functional, but quite new. There might be unexpected bugs.

## Demo

[Demo video (2 minutes)](https://drive.google.com/file/d/1O0dmI9ZiDwMq2JjtxFfM657AUf341pc-/view?usp=sharing)

## See also

* [One-liners for specific Red Hat Konflux use cases](specific-one-liners.md)
* <https://github.com/konflux-ci/build-definitions/>
* <https://gitlab.cee.redhat.com/ynanavat/generate-bulk-tekton-prs/>
