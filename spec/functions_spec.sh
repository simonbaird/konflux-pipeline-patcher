# shellcheck shell=bash

Describe 'get_pinned_task_bundle_ref'
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

Describe 'default_before_task'
  Include ./pipeline-patcher

  Parameters
    "zip zap" "zip" # finds first option
    "zup zap" "zap" # finds second option
    "zup zop" "zop" # finds none but uses last option anyway
  End

  It 'works as expected'
    DEFAULT_BEFORE_TASK_CANDIDATES="$1"
    When call default_before_task ./spec/data/fake_pipeline_run.yaml
    The status should be success
    The output should equal "$2"
  End
End

Describe 'indented'
  Include ./pipeline-patcher

  Parameters
    "foo" "  foo"
    "some more\ntext" "  some more\n  text"
  End

  It 'indents'
    indent_test() {
      printf "$1" | indented
    }
    When call indent_test "$1"
    The status should be success
    The output should equal "$(printf "$2")"
  End
End
