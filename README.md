| 📍 NOTE                                                                                                                                                                                                       |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| RubyGems (the [GitHub org][rubygems-org], not the website) [suffered][draper-security] a [hostile takeover][ellen-takeover] in September 2025.                                                                |
| Ultimately [4 maintainers][simi-removed] were [hard removed][martin-removed] and a reason has been given for only 1 of those, while 2 others resigned in protest.                                             |
| It is a [complicated story][draper-takeover] which is difficult to [parse quickly][draper-lies].                                                                                                              |
| Simply put - there was active policy for adding or removing maintainers/owners of [rubygems][rubygems-maint-policy] and [bundler][bundler-maint-policy], and those [policies were not followed][policy-fail]. |
| I'm adding notes like this to gems because I [don't condone theft][draper-theft] of repositories or gems from their rightful owners.                                                                          |
| If a similar theft happened with my repos/gems, I'd hope some would stand up for me.                                                                                                                          |
| Disenfranchised former-maintainers have started [gem.coop][gem-coop].                                                                                                                                         |
| Once available I will publish there exclusively; unless RubyCentral makes amends with the community.                                                                                                          |
| The ["Technology for Humans: Joel Draper"][reinteractive-podcast] podcast episode by [reinteractive][reinteractive] is the most cogent summary I'm aware of.                                                  |
| See [here][gem-naming], [here][gem-coop] and [here][martin-ann] for more info on what comes next.                                                                                                             |
| What I'm doing: A (WIP) proposal for [bundler/gem scopes][gem-scopes], and a (WIP) proposal for a federated [gem server][gem-server].                                                                         |

[rubygems-org]: https://github.com/rubygems/
[draper-security]: https://joel.drapper.me/p/ruby-central-security-measures/
[draper-takeover]: https://joel.drapper.me/p/ruby-central-takeover/
[ellen-takeover]: https://pup-e.com/blog/goodbye-rubygems/
[simi-removed]: https://www.reddit.com/r/ruby/s/gOk42POCaV
[martin-removed]: https://bsky.app/profile/martinemde.com/post/3m3occezxxs2q
[draper-lies]: https://joel.drapper.me/p/ruby-central-fact-check/
[draper-theft]: https://joel.drapper.me/p/ruby-central/
[reinteractive]: https://reinteractive.com/ruby-on-rails
[gem-coop]: https://gem.coop
[gem-naming]: https://github.com/gem-coop/gem.coop/issues/12
[martin-ann]: https://martinemde.com/2025/10/05/announcing-gem-coop.html
[gem-scopes]: https://github.com/galtzo-floss/bundle-namespace
[gem-server]: https://github.com/galtzo-floss/gem-server
[reinteractive-podcast]: https://youtu.be/_H4qbtC5qzU?si=BvuBU90R2wAqD2E6
[bundler-maint-policy]: https://github.com/ruby/rubygems/blob/b1ab33a3d52310a84d16b193991af07f5a6a07c0/doc/bundler/playbooks/TEAM_CHANGES.md
[rubygems-maint-policy]: https://github.com/ruby/rubygems/blob/b1ab33a3d52310a84d16b193991af07f5a6a07c0/doc/rubygems/POLICIES.md?plain=1#L187-L196
[policy-fail]: https://www.reddit.com/r/ruby/comments/1ove9vp/rubycentral_hates_this_one_fact/

[![Galtzo FLOSS Logo by Aboling0, CC BY-SA 4.0][🖼️galtzo-i]][🖼️galtzo-discord] [![ruby-lang Logo, Yukihiro Matsumoto, Ruby Visual Identity Team, CC BY-SA 2.5][🖼️ruby-lang-i]][🖼️ruby-lang] [![kettle-rb Logo by Aboling0, CC BY-SA 4.0][🖼️kettle-rb-i]][🖼️kettle-rb]

[🖼️galtzo-i]: https://logos.galtzo.com/assets/images/galtzo-floss/avatar-192px.svg
[🖼️galtzo-discord]: https://discord.gg/3qme4XHNKN
[🖼️ruby-lang-i]: https://logos.galtzo.com/assets/images/ruby-lang/avatar-192px.svg
[🖼️ruby-lang]: https://www.ruby-lang.org/
[🖼️kettle-rb-i]: https://logos.galtzo.com/assets/images/kettle-rb/avatar-192px.svg
[🖼️kettle-rb]: https://github.com/kettle-rb

# ☯️ Bash::Merge

[![Version][👽versioni]][👽version] [![GitHub tag (latest SemVer)][⛳️tag-img]][⛳️tag] [![License: MIT][📄license-img]][📄license-ref] [![Downloads Rank][👽dl-ranki]][👽dl-rank] [![Open Source Helpers][👽oss-helpi]][👽oss-help] [![CodeCov Test Coverage][🏀codecovi]][🏀codecov] [![Coveralls Test Coverage][🏀coveralls-img]][🏀coveralls] [![QLTY Test Coverage][🏀qlty-covi]][🏀qlty-cov] [![QLTY Maintainability][🏀qlty-mnti]][🏀qlty-mnt] [![CI Heads][🚎3-hd-wfi]][🚎3-hd-wf] [![CI Runtime Dependencies @ HEAD][🚎12-crh-wfi]][🚎12-crh-wf] [![CI Current][🚎11-c-wfi]][🚎11-c-wf] [![CI Truffle Ruby][🚎9-t-wfi]][🚎9-t-wf] [![Deps Locked][🚎13-🔒️-wfi]][🚎13-🔒️-wf] [![Deps Unlocked][🚎14-🔓️-wfi]][🚎14-🔓️-wf] [![CI Supported][🚎6-s-wfi]][🚎6-s-wf] [![CI Test Coverage][🚎2-cov-wfi]][🚎2-cov-wf] [![CI Style][🚎5-st-wfi]][🚎5-st-wf] [![CodeQL][🖐codeQL-img]][🖐codeQL] [![Apache SkyWalking Eyes License Compatibility Check][🚎15-🪪-wfi]][🚎15-🪪-wf]

`if ci_badges.map(&:color).detect { it != "green"}` ☝️ [let me know][🖼️galtzo-discord], as I may have missed the [discord notification][🖼️galtzo-discord].

---

`if ci_badges.map(&:color).all? { it == "green"}` 👇️ send money so I can do more of this. FLOSS maintenance is now my full-time job.

[![OpenCollective Backers][🖇osc-backers-i]][🖇osc-backers] [![OpenCollective Sponsors][🖇osc-sponsors-i]][🖇osc-sponsors] [![Sponsor Me on Github][🖇sponsor-img]][🖇sponsor] [![Liberapay Goal Progress][⛳liberapay-img]][⛳liberapay] [![Donate on PayPal][🖇paypal-img]][🖇paypal] [![Buy me a coffee][🖇buyme-small-img]][🖇buyme] [![Donate on Polar][🖇polar-img]][🖇polar] [![Donate at ko-fi.com][🖇kofi-img]][🖇kofi]

## 🌻 Synopsis

Bash::Merge is a standalone Ruby module that intelligently merges two versions of a Bash script using tree-sitter AST analysis. It's like a smart "git merge" specifically designed for shell scripts. Built on top of [ast-merge](https://github.com/kettle-rb/ast-merge), it shares the same architecture as [prism-merge](https://github.com/kettle-rb/prism-merge) for Ruby source files.

### Key Features

- **Tree-Sitter Powered**: Uses tree-sitter-bash for accurate AST parsing
- **Script-Aware**: Understands Bash syntax including functions, variables, and commands
- **Intelligent**: Matches functions and variable assignments by name
- **Comment-Preserving**: Comments are preserved in their context
- **Shebang Handling**: Properly handles `#!/bin/bash` and similar shebangs
- **Freeze Block Support**: Respects freeze markers (default: `bash-merge:freeze` / `bash-merge:unfreeze`) for merge control - customizable to match your project's conventions
- **Full Provenance**: Tracks origin of every node
- **Standalone**: Minimal dependencies - just `ast-merge` and `ruby_tree_sitter`
- **Customizable**:
  - `signature_generator` - callable custom signature generators
  - `preference` - setting of `:template`, `:destination`, or a Hash for per-node-type preferences
  - `node_splitter` - Hash mapping node types to callables for per-node-type merge customization (see [ast-merge](https://github.com/kettle-rb/ast-merge) docs)
  - `add_template_only_nodes` - setting to retain nodes that do not exist in destination
  - `freeze_token` - customize freeze block markers (default: `"bash-merge"`)

### Supported Node Types

| Node Type | Signature Format | Matching Behavior |
|-----------|------------------|-------------------|
| Function Definition | `[:function, name]` | Functions match by name |
| Variable Assignment | `[:assignment, name]` | Variables match by name |
| Command | `[:command, name, args...]` | Commands match by name and arguments |
| Comment | `[:comment, text]` | Comments preserved in context |
| Pipeline | `[:pipeline, commands...]` | Pipelines match by command sequence |
| If Statement | `[:if, condition_sig]` | Conditionals match by condition signature |
| For Loop | `[:for, variable]` | For loops match by loop variable |
| While Loop | `[:while, condition_sig]` | While loops match by condition signature |

### Example

```ruby
require "bash/merge"

template = File.read("template.sh")
destination = File.read("destination.sh")

merger = Bash::Merge::SmartMerger.new(template, destination)
result = merger.merge

File.write("merged.sh", result.to_bash)
```

### The `*-merge` Gem Family

This gem is part of a family of gems that provide intelligent merging for various file formats:

| Gem | Format | Parser | Description |
|-----|--------|--------|-------------|
| [ast-merge][ast-merge] | Text | internal | Shared infrastructure for all `*-merge` gems |
| [prism-merge][prism-merge] | Ruby | [Prism][prism] | Smart merge for Ruby source files |
| [psych-merge][psych-merge] | YAML | [Psych][psych] | Smart merge for YAML files |
| [json-merge][json-merge] | JSON | [tree-sitter-json][ts-json] | Smart merge for JSON files |
| [jsonc-merge][jsonc-merge] | JSONC | [tree-sitter-jsonc][ts-jsonc] | ⚠️ Proof of concept; Smart merge for JSON with Comments |
| [bash-merge][bash-merge] | Bash | [tree-sitter-bash][ts-bash] | Smart merge for Bash scripts |
| [rbs-merge][rbs-merge] | RBS | [RBS][rbs] | Smart merge for Ruby type signatures |
| [dotenv-merge][dotenv-merge] | Dotenv | internal ([dotenv][dotenv]) | Smart merge for `.env` files |
| [toml-merge][toml-merge] | TOML | [tree-sitter-toml][ts-toml] | Smart merge for TOML files |
| [markdown-merge][markdown-merge] | Markdown | _base classes_ | Shared foundation for Markdown mergers |
| [markly-merge][markly-merge] | Markdown | [Markly][markly] | Smart merge for Markdown (CommonMark via libcmark-gfm) |
| [commonmarker-merge][commonmarker-merge] | Markdown | [Commonmarker][commonmarker] | Smart merge for Markdown (CommonMark via comrak) |

**Example implementations** for the gem templating use case:

| Gem | Purpose | Description |
|-----|---------|-------------|
| [kettle-dev][kettle-dev] | Gem Development | Gem templating tool using `*-merge` gems |
| [kettle-jem][kettle-jem] | Gem Templating | Gem template library with smart merge support |

[ast-merge]: https://github.com/kettle-rb/ast-merge
[prism-merge]: https://github.com/kettle-rb/prism-merge
[psych-merge]: https://github.com/kettle-rb/psych-merge
[json-merge]: https://github.com/kettle-rb/json-merge
[jsonc-merge]: https://github.com/kettle-rb/jsonc-merge
[bash-merge]: https://github.com/kettle-rb/bash-merge
[rbs-merge]: https://github.com/kettle-rb/rbs-merge
[dotenv-merge]: https://github.com/kettle-rb/dotenv-merge
[toml-merge]: https://github.com/kettle-rb/toml-merge
[markdown-merge]: https://github.com/kettle-rb/markdown-merge
[markly-merge]: https://github.com/kettle-rb/markly-merge
[commonmarker-merge]: https://github.com/kettle-rb/commonmarker-merge
[kettle-dev]: https://github.com/kettle-rb/kettle-dev
[kettle-jem]: https://github.com/kettle-rb/kettle-jem
[prism]: https://github.com/ruby/prism
[psych]: https://github.com/ruby/psych
[ts-json]: https://github.com/tree-sitter/tree-sitter-json
[ts-jsonc]: https://gitlab.com/WhyNotHugo/tree-sitter-jsonc
[ts-bash]: https://github.com/tree-sitter/tree-sitter-bash
[ts-toml]: https://github.com/tree-sitter-grammars/tree-sitter-toml
[rbs]: https://github.com/ruby/rbs
[dotenv]: https://github.com/bkeepers/dotenv
[markly]: https://github.com/kivikakk/markly
[commonmarker]: https://github.com/gjtorikian/commonmarker

## 💡 Info you can shake a stick at

| Tokens to Remember      | [![Gem name][⛳️name-img]][⛳️gem-name] [![Gem namespace][⛳️namespace-img]][⛳️gem-namespace]                                                                                                                                                                                                                                                                          |
|-------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Works with JRuby        | [![JRuby 10.0 Compat][💎jruby-c-i]][🚎11-c-wf] [![JRuby HEAD Compat][💎jruby-headi]][🚎3-hd-wf]                                                                                                          |
| Works with Truffle Ruby | [![Truffle Ruby 23.1 Compat][💎truby-23.1i]][🚎9-t-wf] [![Truffle Ruby 24.1 Compat][💎truby-c-i]][🚎11-c-wf]                                                                                                                                                            |
| Works with MRI Ruby 3   | [![Ruby 3.2 Compat][💎ruby-3.2i]][🚎6-s-wf] [![Ruby 3.3 Compat][💎ruby-3.3i]][🚎6-s-wf] [![Ruby 3.4 Compat][💎ruby-c-i]][🚎11-c-wf] [![Ruby HEAD Compat][💎ruby-headi]][🚎3-hd-wf]                                                                                         |
| Support & Community     | [![Join Me on Daily.dev's RubyFriends][✉️ruby-friends-img]][✉️ruby-friends] [![Live Chat on Discord][✉️discord-invite-img-ftb]][✉️discord-invite] [![Get help from me on Upwork][👨🏼‍🏫expsup-upwork-img]][👨🏼‍🏫expsup-upwork] [![Get help from me on Codementor][👨🏼‍🏫expsup-codementor-img]][👨🏼‍🏫expsup-codementor]                                       |
| Source                  | [![Source on GitLab.com][📜src-gl-img]][📜src-gl] [![Source on CodeBerg.org][📜src-cb-img]][📜src-cb] [![Source on Github.com][📜src-gh-img]][📜src-gh] [![The best SHA: dQw4w9WgXcQ!][🧮kloc-img]][🧮kloc]                                                                                                                                                         |
| Documentation           | [![Current release on RubyDoc.info][📜docs-cr-rd-img]][🚎yard-current] [![YARD on Galtzo.com][📜docs-head-rd-img]][🚎yard-head] [![Maintainer Blog][🚂maint-blog-img]][🚂maint-blog] [![GitLab Wiki][📜gl-wiki-img]][📜gl-wiki] [![GitHub Wiki][📜gh-wiki-img]][📜gh-wiki]                                                                                          |
| Compliance              | [![License: MIT][📄license-img]][📄license-ref] [![Compatible with Apache Software Projects: Verified by SkyWalking Eyes][📄license-compat-img]][📄license-compat] [![📄ilo-declaration-img]][📄ilo-declaration] [![Security Policy][🔐security-img]][🔐security] [![Contributor Covenant 2.1][🪇conduct-img]][🪇conduct] [![SemVer 2.0.0][📌semver-img]][📌semver] |
| Style                   | [![Enforced Code Style Linter][💎rlts-img]][💎rlts] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog] [![Gitmoji Commits][📌gitmoji-img]][📌gitmoji] [![Compatibility appraised by: appraisal2][💎appraisal2-img]][💎appraisal2]                                                                                                                  |
| Maintainer 🎖️          | [![Follow Me on LinkedIn][💖🖇linkedin-img]][💖🖇linkedin] [![Follow Me on Ruby.Social][💖🐘ruby-mast-img]][💖🐘ruby-mast] [![Follow Me on Bluesky][💖🦋bluesky-img]][💖🦋bluesky] [![Contact Maintainer][🚂maint-contact-img]][🚂maint-contact] [![My technical writing][💖💁🏼‍♂️devto-img]][💖💁🏼‍♂️devto]                                                      |
| `...` 💖                | [![Find Me on WellFound:][💖✌️wellfound-img]][💖✌️wellfound] [![Find Me on CrunchBase][💖💲crunchbase-img]][💖💲crunchbase] [![My LinkTree][💖🌳linktree-img]][💖🌳linktree] [![More About Me][💖💁🏼‍♂️aboutme-img]][💖💁🏼‍♂️aboutme] [🧊][💖🧊berg] [🐙][💖🐙hub]  [🛖][💖🛖hut] [🧪][💖🧪lab]                                                                   |

### Compatibility

Compatible with MRI Ruby 3.2.0+, and concordant releases of JRuby, and TruffleRuby.

| 🚚 _Amazing_ test matrix was brought to you by | 🔎 appraisal2 🔎 and the color 💚 green 💚             |
|------------------------------------------------|--------------------------------------------------------|
| 👟 Check it out!                               | ✨ [github.com/appraisal-rb/appraisal2][💎appraisal2] ✨ |

### Federated DVCS

<details markdown="1">
  <summary>Find this repo on federated forges (Coming soon!)</summary>

| Federated [DVCS][💎d-in-dvcs] Repository        | Status                                                                | Issues                    | PRs                      | Wiki                      | CI                       | Discussions                  |
|-------------------------------------------------|-----------------------------------------------------------------------|---------------------------|--------------------------|---------------------------|--------------------------|------------------------------|
| 🧪 [kettle-rb/bash-merge on GitLab][📜src-gl]   | The Truth                                                             | [💚][🤝gl-issues]         | [💚][🤝gl-pulls]         | [💚][📜gl-wiki]           | 🐭 Tiny Matrix           | ➖                            |
| 🧊 [kettle-rb/bash-merge on CodeBerg][📜src-cb] | An Ethical Mirror ([Donate][🤝cb-donate])                             | [💚][🤝cb-issues]         | [💚][🤝cb-pulls]         | ➖                         | ⭕️ No Matrix             | ➖                            |
| 🐙 [kettle-rb/bash-merge on GitHub][📜src-gh]   | Another Mirror                                                        | [💚][🤝gh-issues]         | [💚][🤝gh-pulls]         | [💚][📜gh-wiki]           | 💯 Full Matrix           | [💚][gh-discussions]         |
| 🎮️ [Discord Server][✉️discord-invite]          | [![Live Chat on Discord][✉️discord-invite-img-ftb]][✉️discord-invite] | [Let's][✉️discord-invite] | [talk][✉️discord-invite] | [about][✉️discord-invite] | [this][✉️discord-invite] | [library!][✉️discord-invite] |

</details>

[gh-discussions]: https://github.com/kettle-rb/bash-merge/discussions

### Enterprise Support [![Tidelift](https://tidelift.com/badges/package/rubygems/bash-merge)](https://tidelift.com/subscription/pkg/rubygems-bash-merge?utm_source=rubygems-bash-merge&utm_medium=referral&utm_campaign=readme)

Available as part of the Tidelift Subscription.

<details markdown="1">
  <summary>Need enterprise-level guarantees?</summary>

The maintainers of this and thousands of other packages are working with Tidelift to deliver commercial support and maintenance for the open source packages you use to build your applications. Save time, reduce risk, and improve code health, while paying the maintainers of the exact packages you use.

[![Get help from me on Tidelift][🏙️entsup-tidelift-img]][🏙️entsup-tidelift]

- 💡Subscribe for support guarantees covering _all_ your FLOSS dependencies
- 💡Tidelift is part of [Sonar][🏙️entsup-tidelift-sonar]
- 💡Tidelift pays maintainers to maintain the software you depend on!<br/>📊`@`Pointy Haired Boss: An [enterprise support][🏙️entsup-tidelift] subscription is "[never gonna let you down][🧮kloc]", and *supports* open source maintainers

Alternatively:

- [![Live Chat on Discord][✉️discord-invite-img-ftb]][✉️discord-invite]
- [![Get help from me on Upwork][👨🏼‍🏫expsup-upwork-img]][👨🏼‍🏫expsup-upwork]
- [![Get help from me on Codementor][👨🏼‍🏫expsup-codementor-img]][👨🏼‍🏫expsup-codementor]

</details>

## ✨ Installation

Install the gem and add to the application's Gemfile by executing:

```console
bundle add bash-merge
```

If bundler is not being used to manage dependencies, install the gem by executing:

```console
gem install bash-merge
```

### 🔒 Secure Installation

<details markdown="1">
  <summary>For Medium or High Security Installations</summary>

This gem is cryptographically signed, and has verifiable [SHA-256 and SHA-512][💎SHA_checksums] checksums by
[stone_checksums][💎stone_checksums]. Be sure the gem you install hasn’t been tampered with
by following the instructions below.

Add my public key (if you haven’t already, expires 2045-04-29) as a trusted certificate:

```console
gem cert --add <(curl -Ls https://raw.github.com/galtzo-floss/certs/main/pboling.pem)
```

You only need to do that once.  Then proceed to install with:

```console
gem install bash-merge -P HighSecurity
```

The `HighSecurity` trust profile will verify signed gems, and not allow the installation of unsigned dependencies.

If you want to up your security game full-time:

```console
bundle config set --global trust-policy MediumSecurity
```

`MediumSecurity` instead of `HighSecurity` is necessary if not all the gems you use are signed.

NOTE: Be prepared to track down certs for signed gems and add them the same way you added mine.

</details>

### 🌳 Tree-Sitter Parser Installation

This gem requires the `tree-sitter-bash` parser library to be installed on your system.
The parser is a native shared library (`.so` on Linux, `.dylib` on macOS) that provides
Bash syntax parsing capabilities.

#### Option 1: Pre-built Binaries (Recommended)

Download pre-built parsers from [Faveod/tree-sitter-parsers](https://github.com/Faveod/tree-sitter-parsers/releases):

**Linux (x64):**
```console
# Download and extract
curl -Lo parsers.tar.gz https://github.com/Faveod/tree-sitter-parsers/releases/download/v4.10/tree-sitter-parsers-4.10-linux-x64.tar.gz
tar -xzf parsers.tar.gz

# Install system-wide (requires sudo)
sudo cp libtree-sitter-bash.so /usr/lib/
sudo ldconfig

# Or install locally and set environment variable
mkdir -p ~/.local/lib/tree-sitter
cp libtree-sitter-bash.so ~/.local/lib/tree-sitter/
export TREE_SITTER_BASH_PATH="$HOME/.local/lib/tree-sitter/libtree-sitter-bash.so"
```

**Debian/Ubuntu (amd64):**
```console
curl -Lo parsers.deb https://github.com/Faveod/tree-sitter-parsers/releases/download/v4.10/tree-sitter-parsers-4.10-amd64.deb
sudo dpkg -i parsers.deb
```

**macOS (Apple Silicon):**
```console
curl -Lo parsers.tar.gz https://github.com/Faveod/tree-sitter-parsers/releases/download/v4.10/tree-sitter-parsers-4.10-macos-arm64.tar.gz
tar -xzf parsers.tar.gz

# Install to a location and set environment variable
mkdir -p ~/.local/lib/tree-sitter
cp libtree-sitter-bash.dylib ~/.local/lib/tree-sitter/
export TREE_SITTER_BASH_PATH="$HOME/.local/lib/tree-sitter/libtree-sitter-bash.dylib"
```

#### Option 2: Build from Source

```console
git clone https://github.com/tree-sitter/tree-sitter-bash.git
cd tree-sitter-bash
make
sudo cp libtree-sitter-bash.so /usr/lib/  # Linux
# or
sudo cp libtree-sitter-bash.dylib /usr/local/lib/  # macOS
```

#### Option 3: Package Manager

Some package managers provide tree-sitter parsers:

**Fedora Atomic (Silverblue, Kinoite, Bazzite, Aurora, etc.):**
```console
# Install via rpm-ostree (requires reboot)
rpm-ostree install libtree-sitter-bash

# The library will be installed to /usr/lib64/libtree-sitter-bash.so
# You may need to set the environment variable:
export TREE_SITTER_BASH_PATH="/usr/lib64/libtree-sitter-bash.so"
```

**Fedora (traditional):**
```console
sudo dnf install libtree-sitter-bash
```

**Arch Linux:**
```console
# Check AUR for tree-sitter-bash
yay -S tree-sitter-bash
```

#### Environment Variable

If the parser is not in a standard location (`/usr/lib/`, `/usr/lib64/`, `/usr/local/lib/`),
set the `TREE_SITTER_BASH_PATH` environment variable to point to the parser library:

```console
export TREE_SITTER_BASH_PATH="/path/to/libtree-sitter-bash.so"
```

**Note:** Some distributions install the library with a version number suffix
(e.g., `libtree-sitter-bash.so.14` instead of `libtree-sitter-bash.so`).
If the gem can't find the parser, check for versioned files and either:
- Set `TREE_SITTER_BASH_PATH` to the full versioned path, or
- Create a symlink: `sudo ln -s /usr/lib64/libtree-sitter-bash.so.14 /usr/lib64/libtree-sitter-bash.so`

Add this to your shell profile (`.bashrc`, `.zshrc`, etc.) for persistence.

## ⚙️ Configuration

```ruby
merger = Bash::Merge::SmartMerger.new(
  template_content,
  dest_content,
  # Which version to prefer when nodes match
  # :destination (default) - keep destination code
  # :template - use template code
  preference: :destination,

  # Whether to add template-only nodes to the result
  # false (default) - only include nodes that exist in destination
  # true - include all template nodes (functions, variables, etc.)
  add_template_only_nodes: false,

  # Token for freeze block markers
  # Default: "bash-merge"
  # Looks for: # bash-merge:freeze / # bash-merge:unfreeze
  freeze_token: "bash-merge",

  # Custom signature generator (optional)
  # Receives a node, returns a signature array or nil
  signature_generator: ->(node) { [:function, node.name] if node.type == :function_definition },
)
```

## 🔧 Basic Usage

### Simple Merge

```ruby
require "bash/merge"

# Template defines the structure
template = <<~BASH
  #!/bin/bash
  
  # Configuration
  APP_NAME="myapp"
  DEBUG=false
  
  # Main function
  main() {
    echo "Starting $APP_NAME"
    setup
    run
  }
  
  setup() {
    echo "Setting up..."
  }
  
  run() {
    echo "Running..."
  }
  
  main "$@"
BASH

# Destination has customizations
destination = <<~BASH
  #!/bin/bash
  
  # Configuration
  APP_NAME="myapp-custom"
  DEBUG=true
  LOG_FILE="/var/log/myapp.log"
  
  # Main function with custom logging
  main() {
    echo "Starting $APP_NAME" | tee -a "$LOG_FILE"
    setup
    run
  }
  
  setup() {
    echo "Custom setup..."
  }
  
  main "$@"
BASH

merger = Bash::Merge::SmartMerger.new(template, destination)
result = merger.merge
puts result.to_bash
```

### Using Freeze Blocks

Freeze blocks protect sections from being overwritten during merge:

```bash
#!/bin/bash

# Configuration
APP_NAME="myapp"

# bash-merge:freeze Custom credentials
DB_USER="production_user"
DB_PASS="super_secret_password"
API_KEY="my_production_api_key"
# bash-merge:unfreeze

# Standard functions
main() {
  echo "Starting $APP_NAME"
}

main "$@"
```

Content between `# bash-merge:freeze` and `# bash-merge:unfreeze` markers is preserved from the destination file, regardless of what the template contains.

### Adding Template-Only Nodes

```ruby
merger = Bash::Merge::SmartMerger.new(
  template,
  destination,
  add_template_only_nodes: true,
)
result = merger.merge
# Result includes functions/variables from template that don't exist in destination
```

## 🦷 FLOSS Funding

While kettle-rb tools are free software and will always be, the project would benefit immensely from some funding.
Raising a monthly budget of... "dollars" would make the project more sustainable.

We welcome both individual and corporate sponsors! We also offer a
wide array of funding channels to account for your preferences
(although currently [Open Collective][🖇osc] is our preferred funding platform).

**If you're working in a company that's making significant use of kettle-rb tools we'd
appreciate it if you suggest to your company to become a kettle-rb sponsor.**

You can support the development of kettle-rb tools via
[GitHub Sponsors][🖇sponsor],
[Liberapay][⛳liberapay],
[PayPal][🖇paypal],
[Open Collective][🖇osc]
and [Tidelift][🏙️entsup-tidelift].

| 📍 NOTE                                                                                                                                                                                                              |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| If doing a sponsorship in the form of donation is problematic for your company <br/> from an accounting standpoint, we'd recommend the use of Tidelift, <br/> where you can get a support-like subscription instead. |

### Open Collective for Individuals

Support us with a monthly donation and help us continue our activities. [[Become a backer](https://opencollective.com/kettle-rb#backer)]

NOTE: [kettle-readme-backers][kettle-readme-backers] updates this list every day, automatically.

<!-- OPENCOLLECTIVE-INDIVIDUALS:START -->
No backers yet. Be the first!
<!-- OPENCOLLECTIVE-INDIVIDUALS:END -->

### Open Collective for Organizations

Become a sponsor and get your logo on our README on GitHub with a link to your site. [[Become a sponsor](https://opencollective.com/kettle-rb#sponsor)]

NOTE: [kettle-readme-backers][kettle-readme-backers] updates this list every day, automatically.

<!-- OPENCOLLECTIVE-ORGANIZATIONS:START -->
No sponsors yet. Be the first!
<!-- OPENCOLLECTIVE-ORGANIZATIONS:END -->

[kettle-readme-backers]: https://github.com/kettle-rb/bash-merge/blob/main/exe/kettle-readme-backers

### Another way to support open-source

I’m driven by a passion to foster a thriving open-source community – a space where people can tackle complex problems, no matter how small.  Revitalizing libraries that have fallen into disrepair, and building new libraries focused on solving real-world challenges, are my passions.  I was recently affected by layoffs, and the tech jobs market is unwelcoming. I’m reaching out here because your support would significantly aid my efforts to provide for my family, and my farm (11 🐔 chickens, 2 🐶 dogs, 3 🐰 rabbits, 8 🐈‍ cats).

If you work at a company that uses my work, please encourage them to support me as a corporate sponsor. My work on gems you use might show up in `bundle fund`.

I’m developing a new library, [floss_funding][🖇floss-funding-gem], designed to empower open-source developers like myself to get paid for the work we do, in a sustainable way. Please give it a look.

**[Floss-Funding.dev][🖇floss-funding.dev]: 👉️ No network calls. 👉️ No tracking. 👉️ No oversight. 👉️ Minimal crypto hashing. 💡 Easily disabled nags**

[![OpenCollective Backers][🖇osc-backers-i]][🖇osc-backers] [![OpenCollective Sponsors][🖇osc-sponsors-i]][🖇osc-sponsors] [![Sponsor Me on Github][🖇sponsor-img]][🖇sponsor] [![Liberapay Goal Progress][⛳liberapay-img]][⛳liberapay] [![Donate on PayPal][🖇paypal-img]][🖇paypal] [![Buy me a coffee][🖇buyme-small-img]][🖇buyme] [![Donate on Polar][🖇polar-img]][🖇polar] [![Donate to my FLOSS efforts at ko-fi.com][🖇kofi-img]][🖇kofi] [![Donate to my FLOSS efforts using Patreon][🖇patreon-img]][🖇patreon]

## 🔐 Security

See [SECURITY.md][🔐security].

## 🤝 Contributing

If you need some ideas of where to help, you could work on adding more code coverage,
or if it is already 💯 (see [below](#code-coverage)) check [reek](REEK), [issues][🤝gh-issues], or [PRs][🤝gh-pulls],
or use the gem and think about how it could be better.

We [![Keep A Changelog][📗keep-changelog-img]][📗keep-changelog] so if you make changes, remember to update it.

See [CONTRIBUTING.md][🤝contributing] for more detailed instructions.

### 🚀 Release Instructions

See [CONTRIBUTING.md][🤝contributing].

### Code Coverage

[![Coverage Graph][🏀codecov-g]][🏀codecov]

[![Coveralls Test Coverage][🏀coveralls-img]][🏀coveralls]

[![QLTY Test Coverage][🏀qlty-covi]][🏀qlty-cov]

### 🪇 Code of Conduct

Everyone interacting with this project's codebases, issue trackers,
chat rooms and mailing lists agrees to follow the [![Contributor Covenant 2.1][🪇conduct-img]][🪇conduct].

## 🌈 Contributors

[![Contributors][🖐contributors-img]][🖐contributors]

Made with [contributors-img][🖐contrib-rocks].

Also see GitLab Contributors: [https://gitlab.com/kettle-rb/bash-merge/-/graphs/main][🚎contributors-gl]

<details>
    <summary>⭐️ Star History</summary>

<a href="https://star-history.com/#kettle-rb/bash-merge&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=kettle-rb/bash-merge&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=kettle-rb/bash-merge&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=kettle-rb/bash-merge&type=Date" />
 </picture>
</a>

</details>

## 📌 Versioning

This Library adheres to [![Semantic Versioning 2.0.0][📌semver-img]][📌semver].
Violations of this scheme should be reported as bugs.
Specifically, if a minor or patch version is released that breaks backward compatibility,
a new version should be immediately released that restores compatibility.
Breaking changes to the public API will only be introduced with new major versions.

> dropping support for a platform is both obviously and objectively a breaking change <br/>
>—Jordan Harband ([@ljharb](https://github.com/ljharb), maintainer of SemVer) [in SemVer issue 716][📌semver-breaking]

I understand that policy doesn't work universally ("exceptions to every rule!"),
but it is the policy here.
As such, in many cases it is good to specify a dependency on this library using
the [Pessimistic Version Constraint][📌pvc] with two digits of precision.

For example:

```ruby
spec.add_dependency("bash-merge", "~> 1.0")
```

<details markdown="1">
<summary>📌 Is "Platform Support" part of the public API? More details inside.</summary>

SemVer should, IMO, but doesn't explicitly, say that dropping support for specific Platforms
is a *breaking change* to an API, and for that reason the bike shedding is endless.

To get a better understanding of how SemVer is intended to work over a project's lifetime,
read this article from the creator of SemVer:

- ["Major Version Numbers are Not Sacred"][📌major-versions-not-sacred]

</details>

See [CHANGELOG.md][📌changelog] for a list of releases.

## 📄 License

The gem is available as open source under the terms of
the [MIT License][📄license] [![License: MIT][📄license-img]][📄license-ref].
See [LICENSE.txt][📄license] for the official [Copyright Notice][📄copyright-notice-explainer].

### © Copyright

<ul>
    <li>
        Copyright (c) 2025 Peter H. Boling, of
        <a href="https://discord.gg/3qme4XHNKN">
            Galtzo.com
            <picture>
              <img src="https://logos.galtzo.com/assets/images/galtzo-floss/avatar-128px-blank.svg" alt="Galtzo.com Logo (Wordless) by Aboling0, CC BY-SA 4.0" width="24">
            </picture>
        </a>, and bash-merge contributors.
    </li>
</ul>

## 🤑 A request for help

Maintainers have teeth and need to pay their dentists.
After getting laid off in an RIF in March, and encountering difficulty finding a new one,
I began spending most of my time building open source tools.
I'm hoping to be able to pay for my kids' health insurance this month,
so if you value the work I am doing, I need your support.
Please consider sponsoring me or the project.

To join the community or get help 👇️ Join the Discord.

[![Live Chat on Discord][✉️discord-invite-img-ftb]][✉️discord-invite]

To say "thanks!" ☝️ Join the Discord or 👇️ send money.

[![Sponsor kettle-rb/bash-merge on Open Source Collective][🖇osc-all-bottom-img]][🖇osc] 💌 [![Sponsor me on GitHub Sponsors][🖇sponsor-bottom-img]][🖇sponsor] 💌 [![Sponsor me on Liberapay][⛳liberapay-bottom-img]][⛳liberapay] 💌 [![Donate on PayPal][🖇paypal-bottom-img]][🖇paypal]

### Please give the project a star ⭐ ♥.

Thanks for RTFM. ☺️

[⛳liberapay-img]: https://img.shields.io/liberapay/goal/pboling.svg?logo=liberapay&color=a51611&style=flat
[⛳liberapay-bottom-img]: https://img.shields.io/liberapay/goal/pboling.svg?style=for-the-badge&logo=liberapay&color=a51611
[⛳liberapay]: https://liberapay.com/pboling/donate
[🖇osc-all-img]: https://img.shields.io/opencollective/all/kettle-rb
[🖇osc-sponsors-img]: https://img.shields.io/opencollective/sponsors/kettle-rb
[🖇osc-backers-img]: https://img.shields.io/opencollective/backers/kettle-rb
[🖇osc-backers]: https://opencollective.com/kettle-rb#backer
[🖇osc-backers-i]: https://opencollective.com/kettle-rb/backers/badge.svg?style=flat
[🖇osc-sponsors]: https://opencollective.com/kettle-rb#sponsor
[🖇osc-sponsors-i]: https://opencollective.com/kettle-rb/sponsors/badge.svg?style=flat
[🖇osc-all-bottom-img]: https://img.shields.io/opencollective/all/kettle-rb?style=for-the-badge
[🖇osc-sponsors-bottom-img]: https://img.shields.io/opencollective/sponsors/kettle-rb?style=for-the-badge
[🖇osc-backers-bottom-img]: https://img.shields.io/opencollective/backers/kettle-rb?style=for-the-badge
[🖇osc]: https://opencollective.com/kettle-rb
[🖇sponsor-img]: https://img.shields.io/badge/Sponsor_Me!-pboling.svg?style=social&logo=github
[🖇sponsor-bottom-img]: https://img.shields.io/badge/Sponsor_Me!-pboling-blue?style=for-the-badge&logo=github
[🖇sponsor]: https://github.com/sponsors/pboling
[🖇polar-img]: https://img.shields.io/badge/polar-donate-a51611.svg?style=flat
[🖇polar]: https://polar.sh/pboling
[🖇kofi-img]: https://img.shields.io/badge/ko--fi-%E2%9C%93-a51611.svg?style=flat
[🖇kofi]: https://ko-fi.com/O5O86SNP4
[🖇patreon-img]: https://img.shields.io/badge/patreon-donate-a51611.svg?style=flat
[🖇patreon]: https://patreon.com/galtzo
[🖇buyme-small-img]: https://img.shields.io/badge/buy_me_a_coffee-%E2%9C%93-a51611.svg?style=flat
[🖇buyme-img]: https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20latte&emoji=&slug=pboling&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff
[🖇buyme]: https://www.buymeacoffee.com/pboling
[🖇paypal-img]: https://img.shields.io/badge/donate-paypal-a51611.svg?style=flat&logo=paypal
[🖇paypal-bottom-img]: https://img.shields.io/badge/donate-paypal-a51611.svg?style=for-the-badge&logo=paypal&color=0A0A0A
[🖇paypal]: https://www.paypal.com/paypalme/peterboling
[🖇floss-funding.dev]: https://floss-funding.dev
[🖇floss-funding-gem]: https://github.com/galtzo-floss/floss_funding
[✉️discord-invite]: https://discord.gg/3qme4XHNKN
[✉️discord-invite-img-ftb]: https://img.shields.io/discord/1373797679469170758?style=for-the-badge&logo=discord
[✉️ruby-friends-img]: https://img.shields.io/badge/daily.dev-%F0%9F%92%8E_Ruby_Friends-0A0A0A?style=for-the-badge&logo=dailydotdev&logoColor=white
[✉️ruby-friends]: https://app.daily.dev/squads/rubyfriends

[✇bundle-group-pattern]: https://gist.github.com/pboling/4564780
[⛳️gem-namespace]: https://github.com/kettle-rb/bash-merge
[⛳️namespace-img]: https://img.shields.io/badge/namespace-Bash::Merge-3C2D2D.svg?style=square&logo=ruby&logoColor=white
[⛳️gem-name]: https://bestgems.org/gems/bash-merge
[⛳️name-img]: https://img.shields.io/badge/name-bash--merge-3C2D2D.svg?style=square&logo=rubygems&logoColor=red
[⛳️tag-img]: https://img.shields.io/github/tag/kettle-rb/bash-merge.svg
[⛳️tag]: http://github.com/kettle-rb/bash-merge/releases
[🚂maint-blog]: http://www.railsbling.com/tags/bash-merge
[🚂maint-blog-img]: https://img.shields.io/badge/blog-railsbling-0093D0.svg?style=for-the-badge&logo=rubyonrails&logoColor=orange
[🚂maint-contact]: http://www.railsbling.com/contact
[🚂maint-contact-img]: https://img.shields.io/badge/Contact-Maintainer-0093D0.svg?style=flat&logo=rubyonrails&logoColor=red
[💖🖇linkedin]: http://www.linkedin.com/in/peterboling
[💖🖇linkedin-img]: https://img.shields.io/badge/PeterBoling-LinkedIn-0B66C2?style=flat&logo=newjapanprowrestling
[💖✌️wellfound]: https://wellfound.com/u/peter-boling
[💖✌️wellfound-img]: https://img.shields.io/badge/peter--boling-orange?style=flat&logo=wellfound
[💖💲crunchbase]: https://www.crunchbase.com/person/peter-boling
[💖💲crunchbase-img]: https://img.shields.io/badge/peter--boling-purple?style=flat&logo=crunchbase
[💖🐘ruby-mast]: https://ruby.social/@galtzo
[💖🐘ruby-mast-img]: https://img.shields.io/mastodon/follow/109447111526622197?domain=https://ruby.social&style=flat&logo=mastodon&label=Ruby%20@galtzo
[💖🦋bluesky]: https://bsky.app/profile/galtzo.com
[💖🦋bluesky-img]: https://img.shields.io/badge/@galtzo.com-0285FF?style=flat&logo=bluesky&logoColor=white
[💖🌳linktree]: https://linktr.ee/galtzo
[💖🌳linktree-img]: https://img.shields.io/badge/galtzo-purple?style=flat&logo=linktree
[💖💁🏼‍♂️devto]: https://dev.to/galtzo
[💖💁🏼‍♂️devto-img]: https://img.shields.io/badge/dev.to-0A0A0A?style=flat&logo=devdotto&logoColor=white
[💖💁🏼‍♂️aboutme]: https://about.me/peter.boling
[💖💁🏼‍♂️aboutme-img]: https://img.shields.io/badge/about.me-0A0A0A?style=flat&logo=aboutme&logoColor=white
[💖🧊berg]: https://codeberg.org/pboling
[💖🐙hub]: https://github.org/pboling
[💖🛖hut]: https://sr.ht/~galtzo/
[💖🧪lab]: https://gitlab.com/pboling
[👨🏼‍🏫expsup-upwork]: https://www.upwork.com/freelancers/~014942e9b056abdf86?mp_source=share
[👨🏼‍🏫expsup-upwork-img]: https://img.shields.io/badge/UpWork-13544E?style=for-the-badge&logo=Upwork&logoColor=white
[👨🏼‍🏫expsup-codementor]: https://www.codementor.io/peterboling?utm_source=github&utm_medium=button&utm_term=peterboling&utm_campaign=github
[👨🏼‍🏫expsup-codementor-img]: https://img.shields.io/badge/CodeMentor-Get_Help-1abc9c?style=for-the-badge&logo=CodeMentor&logoColor=white
[🏙️entsup-tidelift]: https://tidelift.com/subscription/pkg/rubygems-bash-merge?utm_source=rubygems-bash-merge&utm_medium=referral&utm_campaign=readme
[🏙️entsup-tidelift-img]: https://img.shields.io/badge/Tidelift_and_Sonar-Enterprise_Support-FD3456?style=for-the-badge&logo=sonar&logoColor=white
[🏙️entsup-tidelift-sonar]: https://blog.tidelift.com/tidelift-joins-sonar
[💁🏼‍♂️peterboling]: http://www.peterboling.com
[🚂railsbling]: http://www.railsbling.com
[📜src-gl-img]: https://img.shields.io/badge/GitLab-FBA326?style=for-the-badge&logo=Gitlab&logoColor=orange
[📜src-gl]: https://gitlab.com/kettle-rb/bash-merge/
[📜src-cb-img]: https://img.shields.io/badge/CodeBerg-4893CC?style=for-the-badge&logo=CodeBerg&logoColor=blue
[📜src-cb]: https://codeberg.org/kettle-rb/bash-merge
[📜src-gh-img]: https://img.shields.io/badge/GitHub-238636?style=for-the-badge&logo=Github&logoColor=green
[📜src-gh]: https://github.com/kettle-rb/bash-merge
[📜docs-cr-rd-img]: https://img.shields.io/badge/RubyDoc-Current_Release-943CD2?style=for-the-badge&logo=readthedocs&logoColor=white
[📜docs-head-rd-img]: https://img.shields.io/badge/YARD_on_Galtzo.com-HEAD-943CD2?style=for-the-badge&logo=readthedocs&logoColor=white
[📜gl-wiki]: https://gitlab.com/kettle-rb/bash-merge/-/wikis/home
[📜gh-wiki]: https://github.com/kettle-rb/bash-merge/wiki
[📜gl-wiki-img]: https://img.shields.io/badge/wiki-examples-943CD2.svg?style=for-the-badge&logo=gitlab&logoColor=white
[📜gh-wiki-img]: https://img.shields.io/badge/wiki-examples-943CD2.svg?style=for-the-badge&logo=github&logoColor=white
[👽dl-rank]: https://bestgems.org/gems/bash-merge
[👽dl-ranki]: https://img.shields.io/gem/rd/bash-merge.svg
[👽oss-help]: https://www.codetriage.com/kettle-rb/bash-merge
[👽oss-helpi]: https://www.codetriage.com/kettle-rb/bash-merge/badges/users.svg
[👽version]: https://bestgems.org/gems/bash-merge
[👽versioni]: https://img.shields.io/gem/v/bash-merge.svg
[🏀qlty-mnt]: https://qlty.sh/gh/kettle-rb/projects/bash-merge
[🏀qlty-mnti]: https://qlty.sh/gh/kettle-rb/projects/bash-merge/maintainability.svg
[🏀qlty-cov]: https://qlty.sh/gh/kettle-rb/projects/bash-merge/metrics/code?sort=coverageRating
[🏀qlty-covi]: https://qlty.sh/gh/kettle-rb/projects/bash-merge/coverage.svg
[🏀codecov]: https://codecov.io/gh/kettle-rb/bash-merge
[🏀codecovi]: https://codecov.io/gh/kettle-rb/bash-merge/graph/badge.svg
[🏀coveralls]: https://coveralls.io/github/kettle-rb/bash-merge?branch=main
[🏀coveralls-img]: https://coveralls.io/repos/github/kettle-rb/bash-merge/badge.svg?branch=main
[🖐codeQL]: https://github.com/kettle-rb/bash-merge/security/code-scanning
[🖐codeQL-img]: https://github.com/kettle-rb/bash-merge/actions/workflows/codeql-analysis.yml/badge.svg
[🚎2-cov-wf]: https://github.com/kettle-rb/bash-merge/actions/workflows/coverage.yml
[🚎2-cov-wfi]: https://github.com/kettle-rb/bash-merge/actions/workflows/coverage.yml/badge.svg
[🚎3-hd-wf]: https://github.com/kettle-rb/bash-merge/actions/workflows/heads.yml
[🚎3-hd-wfi]: https://github.com/kettle-rb/bash-merge/actions/workflows/heads.yml/badge.svg
[🚎5-st-wf]: https://github.com/kettle-rb/bash-merge/actions/workflows/style.yml
[🚎5-st-wfi]: https://github.com/kettle-rb/bash-merge/actions/workflows/style.yml/badge.svg
[🚎6-s-wf]: https://github.com/kettle-rb/bash-merge/actions/workflows/supported.yml
[🚎6-s-wfi]: https://github.com/kettle-rb/bash-merge/actions/workflows/supported.yml/badge.svg
[🚎9-t-wf]: https://github.com/kettle-rb/bash-merge/actions/workflows/truffle.yml
[🚎9-t-wfi]: https://github.com/kettle-rb/bash-merge/actions/workflows/truffle.yml/badge.svg
[🚎11-c-wf]: https://github.com/kettle-rb/bash-merge/actions/workflows/current.yml
[🚎11-c-wfi]: https://github.com/kettle-rb/bash-merge/actions/workflows/current.yml/badge.svg
[🚎12-crh-wf]: https://github.com/kettle-rb/bash-merge/actions/workflows/dep-heads.yml
[🚎12-crh-wfi]: https://github.com/kettle-rb/bash-merge/actions/workflows/dep-heads.yml/badge.svg
[🚎13-🔒️-wf]: https://github.com/kettle-rb/bash-merge/actions/workflows/locked_deps.yml
[🚎13-🔒️-wfi]: https://github.com/kettle-rb/bash-merge/actions/workflows/locked_deps.yml/badge.svg
[🚎14-🔓️-wf]: https://github.com/kettle-rb/bash-merge/actions/workflows/unlocked_deps.yml
[🚎14-🔓️-wfi]: https://github.com/kettle-rb/bash-merge/actions/workflows/unlocked_deps.yml/badge.svg
[🚎15-🪪-wf]: https://github.com/kettle-rb/bash-merge/actions/workflows/license-eye.yml
[🚎15-🪪-wfi]: https://github.com/kettle-rb/bash-merge/actions/workflows/license-eye.yml/badge.svg
[💎ruby-3.2i]: https://img.shields.io/badge/Ruby-3.2-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-3.3i]: https://img.shields.io/badge/Ruby-3.3-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-c-i]: https://img.shields.io/badge/Ruby-current-CC342D?style=for-the-badge&logo=ruby&logoColor=green
[💎ruby-headi]: https://img.shields.io/badge/Ruby-HEAD-CC342D?style=for-the-badge&logo=ruby&logoColor=blue
[💎truby-23.1i]: https://img.shields.io/badge/Truffle_Ruby-23.1-34BCB1?style=for-the-badge&logo=ruby&logoColor=pink
[💎truby-c-i]: https://img.shields.io/badge/Truffle_Ruby-current-34BCB1?style=for-the-badge&logo=ruby&logoColor=green
[💎truby-headi]: https://img.shields.io/badge/Truffle_Ruby-HEAD-34BCB1?style=for-the-badge&logo=ruby&logoColor=blue
[💎jruby-c-i]: https://img.shields.io/badge/JRuby-current-FBE742?style=for-the-badge&logo=ruby&logoColor=green
[💎jruby-headi]: https://img.shields.io/badge/JRuby-HEAD-FBE742?style=for-the-badge&logo=ruby&logoColor=blue
[🤝gh-issues]: https://github.com/kettle-rb/bash-merge/issues
[🤝gh-pulls]: https://github.com/kettle-rb/bash-merge/pulls
[🤝gl-issues]: https://gitlab.com/kettle-rb/bash-merge/-/issues
[🤝gl-pulls]: https://gitlab.com/kettle-rb/bash-merge/-/merge_requests
[🤝cb-issues]: https://codeberg.org/kettle-rb/bash-merge/issues
[🤝cb-pulls]: https://codeberg.org/kettle-rb/bash-merge/pulls
[🤝cb-donate]: https://donate.codeberg.org/
[🤝contributing]: CONTRIBUTING.md
[🏀codecov-g]: https://codecov.io/gh/kettle-rb/bash-merge/graphs/tree.svg
[🖐contrib-rocks]: https://contrib.rocks
[🖐contributors]: https://github.com/kettle-rb/bash-merge/graphs/contributors
[🖐contributors-img]: https://contrib.rocks/image?repo=kettle-rb/bash-merge
[🚎contributors-gl]: https://gitlab.com/kettle-rb/bash-merge/-/graphs/main
[🪇conduct]: CODE_OF_CONDUCT.md
[🪇conduct-img]: https://img.shields.io/badge/Contributor_Covenant-2.1-259D6C.svg
[📌pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint
[📌semver]: https://semver.org/spec/v2.0.0.html
[📌semver-img]: https://img.shields.io/badge/semver-2.0.0-259D6C.svg?style=flat
[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📌changelog]: CHANGELOG.md
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-34495e.svg?style=flat
[📌gitmoji]: https://gitmoji.dev
[📌gitmoji-img]: https://img.shields.io/badge/gitmoji_commits-%20%F0%9F%98%9C%20%F0%9F%98%8D-34495e.svg?style=flat-square
[🧮kloc]: https://www.youtube.com/watch?v=dQw4w9WgXcQ
[🧮kloc-img]: https://img.shields.io/badge/KLOC-4.308-FFDD67.svg?style=for-the-badge&logo=YouTube&logoColor=blue
[🔐security]: SECURITY.md
[🔐security-img]: https://img.shields.io/badge/security-policy-259D6C.svg?style=flat
[📄copyright-notice-explainer]: https://opensource.stackexchange.com/questions/5778/why-do-licenses-such-as-the-mit-license-specify-a-single-year
[📄license]: LICENSE.txt
[📄license-ref]: https://opensource.org/licenses/MIT
[📄license-img]: https://img.shields.io/badge/License-MIT-259D6C.svg
[📄license-compat]: https://dev.to/galtzo/how-to-check-license-compatibility-41h0
[📄license-compat-img]: https://img.shields.io/badge/Apache_Compatible:_Category_A-%E2%9C%93-259D6C.svg?style=flat&logo=Apache
[📄ilo-declaration]: https://www.ilo.org/declaration/lang--en/index.htm
[📄ilo-declaration-img]: https://img.shields.io/badge/ILO_Fundamental_Principles-✓-259D6C.svg?style=flat
[🚎yard-current]: http://rubydoc.info/gems/bash-merge
[🚎yard-head]: https://bash-merge.galtzo.com
[💎stone_checksums]: https://github.com/galtzo-floss/stone_checksums
[💎SHA_checksums]: https://gitlab.com/kettle-rb/bash-merge/-/tree/main/checksums
[💎rlts]: https://github.com/rubocop-lts/rubocop-lts
[💎rlts-img]: https://img.shields.io/badge/code_style_&_linting-rubocop--lts-34495e.svg?plastic&logo=ruby&logoColor=white
[💎appraisal2]: https://github.com/appraisal-rb/appraisal2
[💎appraisal2-img]: https://img.shields.io/badge/appraised_by-appraisal2-34495e.svg?plastic&logo=ruby&logoColor=white
[💎d-in-dvcs]: https://railsbling.com/posts/dvcs/put_the_d_in_dvcs/
