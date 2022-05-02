import requests as rq
import subprocess

with open("k3s-images.txt") as f:
    img_names = f.read().splitlines()

new_tags = [i.replace("docker.io", "docker.service:5000") for i in img_names]

def tag_img(old_tag, new_tag):
    subprocess.run(["docker", "tag", old_tag, new_tag])

[tag_img(o,n) for o, n in zip(img_names, new_tags)]

def push_img(tag):
    subprocess.run(["docker", "image", "push", tag])

[push_img(i)for i in new_tags]

def rm_img(tag):
    subprocess.run(["docker", "image", "rm", tag])

# clean up - dont want these in my local images
[rm_img(i)for i in new_tags]
[rm_img(i)for i in img_names]