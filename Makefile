nothing:
	echo "nada"

salvar:
	git status
	git add .
	git commit -m "guardar cambios"
	git push