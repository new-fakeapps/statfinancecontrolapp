#!/bin/sh

function _usage()
{
  cat <<EOF

USAGE: make <[options]>

OPTIONS:

    -h   --help                       Show this message

    -u   --update                     Update dependencies before generation
    --no-open                         Do not open project file after generation
EOF
exit 1
}


# A string with command options
options=$@

# An array with all the arguments
arguments=($options)

# Loop index
index=0

for argument in $options
  do
    # Incrementing index
    index=`expr $index + 1`

    # The conditions
    case $argument in
      -h | --help) _usage ;;
      -u | --update) sh update.sh ;;
      --no-open) noOpen="--no-open" ;;
    esac
  done

cd ../
tuist clean plugins generatedAutomationProjects projectDescriptionHelpers manifests

tuist generate $noOpen

