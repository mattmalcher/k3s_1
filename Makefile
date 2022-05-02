release=v1.23.6%2Bk3s1
img_folder=resources
local_reg=http://docker.service:5000

ag_img_get:
	mkdir -p $(img_folder)
	cd $(img_folder) && curl -O -L -C - https://github.com/k3s-io/k3s/releases/download/$(release)/k3s
	cd $(img_folder) && curl -O -L -C - https://github.com/k3s-io/k3s/releases/download/$(release)/k3s-images.txt
	cd $(img_folder) && curl -O -L -C - https://github.com/k3s-io/k3s/releases/download/$(release)/k3s-airgap-images-amd64.tar.gz

ag_img_load:
	docker image load -i $(img_folder)/k3s-airgap-images-amd64.tar.gz 

ag_img_push_rm:
	cd $(img_folder) && python3 upload_local.py


	
