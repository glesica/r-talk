slides:
	pandoc -S -t beamer -o slides.pdf slides.md
	pandoc -S -o slides-doc.pdf slides.md
