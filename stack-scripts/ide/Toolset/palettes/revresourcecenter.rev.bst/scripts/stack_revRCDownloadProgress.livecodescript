script "stack_revRCDownloadProgress"
-- Stack file: ide/Toolset/palettes/revresourcecenter.rev
-- Object: stack "revResourceCenter" > substack "revRCDownloadProgress"
-- Made from the stack by tools/oxt/stack-scripts.sh; the stack holds
-- the script that runs, so change it there, not here.

on preOpenStack
   updateProgress 0
end preOpenStack

command updateProgress pPercentage
   set the thumbPosition of scrollbar "Progress" of me to pPercentage
end updateProgress

on preOpenCard
end preOpenCard

on openCard
end openCard

on escapeKey
   resourceDownloadCancel
   close this stack
end escapeKey
