# shellcheck shell=bash

Describe 'command smoke test'
  It 'shows help'
    When run ./pipeline-patcher help
    The status should be success
    The stdout should include "Konflux Pipeline Patcher"
    The stdout should include "Usage:"
  End

  It 'lists tasks'
    # Beware this pulls data from github
    When run ./pipeline-patcher list-tasks
    The status should be success
    The stdout line 1 should eq "apply-tags 0.1"
    The stdout should include "git-clone "
    The stdout should include "clair-scan "
  End

  It 'shows task yaml'
    # Beware this pulls data from github
    When run ./pipeline-patcher task-yaml git-clone
    The status should be success
    # Just a sanity check
    The stdout line 1 should eq "- name: clone-repository"
    The stdout should include "        value: quay.io/konflux-ci/tekton-catalog/task-git-clone:"
    The stdout should include "    resolver: bundles"
  End
End

Describe 'misc helpers'
  Include ./pipeline-patcher

  It 'indents'
    indent_test() {
      printf "some\ntext" | indented
    }
    When call indent_test
    The status should be success
    The output should equal "$(printf "  some\n  text")"
  End
End

Describe 'task-refs'
  Include ./pipeline-patcher

  Parameters
    "foo:0.1"
    "quay.io/konflux-ci/tekton-catalog/task-foo:0.1"
    "quay.io/konflux-ci/tekton-catalog/task-foo:0.1@sha256:whatever"
    "foo" "0.1"
  End

  It 'produces task refs'
    trusted_task_data() {
      cat ./spec/data/fake_trusted_tasks.yaml
    }
    When call get_pinned_task_bundle_ref "$1" ${2:-""}
    The status should be success
    The stdout should equal "quay.io/konflux-ci/tekton-catalog/task-foo:0.1@sha256:somesha"
  End
End
