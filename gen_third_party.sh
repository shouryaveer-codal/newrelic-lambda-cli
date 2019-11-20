#!/bin/sh
PROJECT=$(basename $PWD)

function getdeps {
  REQSFILE=$1; shift
  (
    TMPINSTALL=`mktemp -d /tmp/${PROJECT}-getdeps.XXXXXX` || exit 1

    (
      # Record install deps
      if [ ! -d $TMPINSTALL/pyenv ]; then
        virtualenv $TMPINSTALL/pyenv
      fi
    ) 2>&1 >/dev/null

    # Activate pyenv
    . $TMPINSTALL/pyenv/bin/activate

    # Isolate output from installations
    (
      pip install pip-licenses;
      pip install -r $REQSFILE
    ) 2>&1 >/dev/null

    # Generate markdown report
    pip-licenses --format=markdown
  )
}

cat <<EOF > THIRD_PARTY_NOTICES.md
# Third Party Notices

The $PROJECT uses source code from third party libraries which carry their own copyright notices and license terms. These notices are provided below.

 the event that a required notice is missing or incorrect, please notify us by e-mailing open-source@newrelic.com.

r any licenses that require the disclosure of source code, the source code can be found at https://github.com/newrelic/$PROJECT.

# Content

**[dependencies](#dependencies)**

**[devDependencies](#devdependencies)**

# Dependencies

$(getdeps requirements.txt)

# DevDependencies

$(getdeps dev-requirements.txt)
EOF
