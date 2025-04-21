# shellcheck shell=bash

Describe 'bump-task-refs'
  # Set up a git repo with a fake pipeline in it
  tmp_dir=$(mktemp -d)
  trap "rm -rf $tmp_dir" EXIT
  (
    mkdir $tmp_dir/.tekton
    cp spec/data/fake_pipeline_run.yaml $tmp_dir/.tekton
    cd $tmp_dir && git init . && git add .tekton/* && git commit -m "Testing"
  ) > /dev/null

  show_diff() {
    cd $tmp_dir && git diff
  }

  It 'produces expected output'
    # Beware this pulls data from both github and quay
    When run ./pipeline-patcher bump-task-refs $tmp_dir
    The status should be success
    The output should include "quay.io/konflux-ci/tekton-catalog/task-git-clone-oci-ta:0.1 updated to sha256:"
    The value "$(show_diff)" should include "-              value: quay.io/konflux-ci/tekton-catalog/task-git-clone-oci-ta:0.1@sha256:spam"
    The value "$(show_diff)" should include "+              value: quay.io/konflux-ci/tekton-catalog/task-git-clone-oci-ta:0.1@sha256:"
  End
End
