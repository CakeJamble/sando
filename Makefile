project = project
include $(project)/Makefile

love = /mnt/c/Program\ Files/LOVE
fullname = $(project)/build/$(name)

all: web

web: clean_web $(fullname).love
	mkdir -p $(project)/build/web
	npx love.js $(fullname).love $(project)/build/web -t $(name) $(web_options)
	[ -f "$(project)/index.html" ] && cp $(project)/index.html $(project)/build/web/ || :

$(fullname).love: clean_love
	mkdir -p $(project)/build
	cd $(project) && zip -9 -r build/$(name).love . \
			-x Makefile \
			-x build/**\* \
			-x build/ \
			-x .git/**\* \
			-x .git/ \
			-x .vscode/**\* \
			-x .vscode/ \
			-x .gitignore

deploy: deploy_web

deploy_web: web
	cd $(project)/build/web && zip -9 -r $(name).zip .
	butler push $(project)/build/web/$(name).zip $(itchio):web

clean: clean_web

clean_web: 
	rm -rf $(project)/build/web

clean_love: 
	rm -f $(project)/build/$(name).love

play: 
	cd $(project) && $(love)/love.exe .
