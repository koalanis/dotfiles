function sync_fish_config
pushd ~/.config
git stash
git add fish
git commit -m "sync fish functions"
git push origin main
git stash apply
popd
end
