---
  title: Spelling Check in Vim 
  categories: Vim
  tags: 
    - vim
    - spelling
---

# Problematic

More and more frequent, instead of using professional text processing tools as word or excel, I am using vim for multiple types of documentation. For example, I enjoy using vim editing Latex and Markdown files, and having all the snippets set up. 

Now the problem are : 

- I could not be informed my Spelling Errors: French and English are not my mother ton, I often make a LARGE amount of spelling errors while typing, and even worse, I often mix up these two languages. 
- I should have the method switch between these two languages: English is an international language, but I am living in France, so, you know.


# Solutions

Without any extra plugin which will slow down my system installed. The native solution is: 

~~~vim
autocmd Bufenter *.txt set spell spelllang=en
autocmd Bufenter *.tex set spell spelllang=en
autocmd Bufenter *.md set spell spelllang=en
autocmd Bufenter *.markdown set spell spelllang=en
" spell checking
function! ToggleSpellLang()
	" toggle between en and fr
	if &spelllang =~# 'en'
		:set spelllang=fr
	else
		:set spelllang=en
	endif
endfunction
nnoremap <F7> :setlocal spell!<CR> " toggle spell on or off
nnoremap <F8> :call ToggleSpellLang()<CR> " toggle language

command Spellen set spell spelllang=en
command Spellfr set spell spelllang=fr
~~~

Adding this in to ~/.vimrc, And the hotkeys are : 

| Key | Function | 
|:----------------|:----------------|
| <F7> | Set Spelling Check on/off |
| <F8> | Switch between En/FR |
| ]s | jump to next error |
| [s | Jump back to previous error |
| z= | Choose from the check list | 
| zg | Add into user's dict |
| zw | Remove from user's dict |
