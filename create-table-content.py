import os
import fnmatch
import json


def find_pattern(pattern, path):
    result = []
    for root, dirs, files in os.walk(path):
        for name in files:
            if fnmatch.fnmatch(name, pattern):
                result.append(os.path.join(root, name))
    return result


# result = find_pattern('*.md', '.')
# print(json.dumps(result, indent=4, sort_keys=True))

with open('README.md', 'w+') as f:
    f.write("# Tech note\n\nThis repo is my note about technical\n\n")
    f.write("**NOTE**: The easy way to get all document about any tool is search with key work: 'awesome-[tool name]'\n\n")
    f.write("**Chú ý**: Cách nhanh nhất để tìm tài liệu đầy đủ về một công cụ nào đó là tìm với từ khóa: 'awesome-[tên công cụ]'\n\n")

    f.write("database\n---\n\n")
    results = find_pattern("*.md", "database")
    for _file in results:
        f.write("[{}]({})\n\n".format(os.path.basename(_file), _file))

    f.write("devops\n---\n\n")
    results = find_pattern("*.md", "devops")
    for _file in results:
        f.write("[{}]({})\n\n".format(os.path.basename(_file), _file))

    f.write("programming\n---\n\n")
    results = find_pattern("*.md", "programming")
    for _file in results:
        f.write("[{}]({})\n\n".format(os.path.basename(_file), _file))
        
    f.write("linux\n---\n\n")
    results = find_pattern("*.md", "linux")
    for _file in results:
        f.write("[{}]({})\n\n".format(os.path.basename(_file), _file))

        
    # print(json.dumps(result, indent=4, sort_keys=True))