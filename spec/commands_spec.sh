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
    The stdout line 1 should eq "apply-tags 0.2"
    The stdout should include "git-clone "
    The stdout should include "clair-scan "
  End

  It 'shows task yaml'
    # Beware this pulls data from github
    When run ./pipeline-patcher task-yaml git-clone
    The status should be success
    The stdout line 1 should eq "- name: clone-repository"
    The stdout should include "        value: quay.io/konflux-ci/tekton-catalog/task-git-clone:"
    The stdout should include "    resolver: bundles"
  End

  It 'shows task yaml for tkn-bundle task'
    # Beware this pulls data from github
    When run ./pipeline-patcher task-yaml tkn-bundle-oci-ta
    The status should be success
    The stdout line 1 should eq "- name: build-container"
    The stdout should include "        value: quay.io/konflux-ci/tekton-catalog/task-tkn-bundle-oci-ta:0."
  End

  It 'looks up trusted task data in the konflux catalog'
    When run ./pipeline-patcher trusted-task-lookup buildah
    The status should be success
    The stdout should include "oci://quay.io/konflux-ci/tekton-catalog/task-buildah:0.4"
    The stdout should include "  - ref: sha256:"
  End

  It 'looks up trusted task data in the vanguard catalog'
    When run ./pipeline-patcher trusted-task-lookup rpms-signature-scan
    The status should be success
    The stdout should include "oci://quay.io/konflux-ci/konflux-vanguard/task-rpms-signature-scan:0.2"
    The stdout should include "  - ref: sha256:"
  End

  It 'formats yaml'
    tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" EXIT

    before=$(printf "foo:\n- 2\n- 3\n")
    after=$(printf "foo:\n  - 2\n  - 3\n")

    mkdir $tmp_dir/.tekton
    echo "$before" > $tmp_dir/.tekton/spam.yaml

    When run ./pipeline-patcher format-yaml $tmp_dir
    The status should be success
    The stdout should eq ""
    The value "$(cat "$tmp_dir/.tekton/spam.yaml")" should eq "$after"
  End
End
