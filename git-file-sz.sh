git rev-list --objects --all | awk '{print $1}' | while read obj; do
    size=$(git cat-file -s $obj 2>/dev/null)
    path=$(git rev-list --objects --all | grep $obj | awk '{print $2}')
    if [ -n "$path" ]; then
        echo "$size $path"
    fi
done | sort -nr | head -20

