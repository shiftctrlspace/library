# Library roles

This directory contains the various Ansible roles needed to deploy a Calibre Library host. Of these, the most obvious is the `[calibre](calibre/)` role. It performs the final steps of actually getting the Calibre software (such as the content server) up and running after the rest of the system has been provisioned.

The supporting roles, such as [`tor`](tor/), are responsible for complementary or supporting features.
