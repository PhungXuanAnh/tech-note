- [1. format](#1-format)
- [2. add or subtract N hours/minutes/seconds](#2-add-or-subtract-n-hoursminutesseconds)

# 1. format

```shell
date '+%Y-%m-%d %T'
date '+%Y-%m-%d %H:%M:%S'
```

# 2. add or subtract N hours/minutes/seconds

human format

```shell
date --date="+15 minutes" '+%Y-%m-%d %T'
date '+%Y-%m-%d %T'
date --date="-15 minutes" '+%Y-%m-%d %T'

date --date="+1 hours" '+%Y-%m-%d %T'
date '+%Y-%m-%d %T'
date --date="-1 hours" '+%Y-%m-%d %T'
```

utc format

```shell
date +%s -d '+1 hours'
date +%s
date +%s -d '-1 hours' 
```