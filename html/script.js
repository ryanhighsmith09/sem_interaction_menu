let options = [];
let currentIndex = 1;
const menuDiv = document.getElementById('menu');

window.addEventListener('message', function(event){
    const data = event.data;
    if(data.action==="openMenu"){ options=data.options; currentIndex=data.highlight; renderMenu(); menuDiv.classList.add('open'); }
    if(data.action==="closeMenu"){ menuDiv.classList.remove('open'); }
    if(data.action==="highlight"){ currentIndex=data.index; renderMenu(); }
});

function renderMenu(){
    menuDiv.innerHTML="";
    options.forEach((opt,i)=>{
        const div=document.createElement('div');
        div.className="option"+((i+1)===currentIndex?" highlight":"");
        div.textContent=opt.label;

        div.onmouseenter=()=>{ fetch(`https://${GetParentResourceName()}/highlightOption`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({index:i+1})}) };
        div.onclick=()=>{ fetch(`https://${GetParentResourceName()}/selectOption`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({index:i+1})}) };

        menuDiv.appendChild(div);
    });
}
