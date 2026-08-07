[//]: # (Copyright lowRISC contributors \(OpenTitan project\).)
[//]: # (Licensed under the Apache License, Version 2.0, see LICENSE for details.)
[//]: # (SPDX-License-Identifier: Apache-2.0)

# Contributing code to the `opentitan-signing-infra` repository

This repository was split off from the [OpenTitan project](https://github.com/lowRISC/opentitan/), where it originally resided.
As such, many of the same contribution guidelines used there apply for this project.
Please see [Contributing to OpenTitan](https://opentitan.org/book/doc/contributing) for more detailed guidance.

## Contributor License Agreement

Contributions to OpenTitan must be accompanied by sign-off text that indicates
acceptance of the Contributor License Agreement (see [CLA](CLA) for full text),
which is closely derived from the Apache Individual Contributor License
Agreement. The sign-off text must be included once per commit, in the commit
message. The sign-off can be automatically inserted using a command such as
`git commit -s`, which will generate the text in the form:
`Signed-off-by: Random J Developer <random@developer.example.org>`

By adding this sign-off, you are certifying:

_By signing-off on this submission, I agree to be bound by the terms of the
Contributor License Agreement located at the root of the project repository,
and I agree that this submission constitutes a "Contribution" under that
Agreement._

Please note that this project and any contributions to it are public and that
a record of all contributions (including any personal information submitted
with it, including a sign-off) is maintained indefinitely and may be
redistributed consistent with this project or the open source license(s)
involved.

### Organisational Agreement

Under the [CLA](CLA) a Grant of Copyright License is given by the individual to the Project.
To ensure that the individual is authorised to give this grant, individuals need to be identified as
a [Partner Individual](https://github.com/lowRISC/opentitan/blob/master/doc/project_governance/useraccounts.md#partner-individuals)
or an [Individual Collaborator](https://github.com/lowRISC/opentitan/blob/master/doc/project_governance/useraccounts.md#individual-collaborators)
with an appropriate agreement.

## Copyright messages

To avoid large numbers of attribution or copyright notices cluttering the codebase, copyright is indicated in OpenTitan project files by a generic header:

`Copyright lowRISC contributors (OpenTitan project).`

Detailed and up-to-date attribution for all contributions is available via the Git version control system:
- `git shortlog --author "<your name>"` lists all contributions under your name.
- `git shortlog --author "<organization's domain>"` lists all contributions by an organization.
- `git shortlog -- <path>` lists all contributors for a file or directory tree.
