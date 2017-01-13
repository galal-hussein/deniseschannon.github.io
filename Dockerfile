FROM starefossen/github-pages

ENV VER="v1.0"

RUN git clone https://github.com/galal-hussein/galal-hussein.github.io.git temp \
 && git --git-dir=./temp/.git --work-tree=./temp checkout ${VER} \
 && mkdir -p vbuild/${VER} \
 && jekyll build -s temp -d vbuild/${VER} \
 && find vbuild/${VER} -type f -name '*.html' -print0 | xargs -0 sed -i 's#href="/rancher/'"$VER"'/#href="/rancher/en#g' \
 && find vbuild/${VER} -type f -name '*.html' -print0 | xargs -0 sed -i 's#src="/rancher/'"$VER"'/#src="/rancher/en#g' \ 
 && rm -rf temp

CMD jekyll serve -s /usr/src/app/vbuild/${VER} --no-watch -H 0.0.0.0 -P 4000
