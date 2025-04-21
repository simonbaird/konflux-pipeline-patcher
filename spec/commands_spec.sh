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
End
