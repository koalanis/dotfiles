function sync_fish_config
pushd ~/.config
git add fish
git commit -m "sync fish functions"
git push origin main
popd
end
