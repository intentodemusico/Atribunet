# -*- coding: utf-8 -*-
"""
Created on Mon Mar 23 16:24:15 2020

@authors: Intentodemusico
"""
#Scraping distribui2
from mpi4py import MPI
from bs4 import BeautifulSoup
import json, urllib.request
import numpy as np
def getGoogle(x,letra):
    global rank
    #Es necesario pasar un User-Agent en la cabecera para evitar errores con los controles de seguridad de ciertas páginas
    query="https://www.google.com/search?q="+letra
    url = urllib.request.Request(query, headers={'User-Agent': 'Mozilla/5.0'})
    req = urllib.request.urlopen(url)
    page = req.read()
    print(rank,letra,x)
    #Escogemos el encoder que vamos a usar
    scraping = BeautifulSoup(page,features="html.parser")
    #Al encontrar la etiqueta que queremos, podemos obtener subetiquetas (en este caso div) y el texto que se encuentra en ellas
    title = scraping.findAll("a")[x+17].div.get_text()
    #Con parent podemos referenciar a la etiqueta padre de la que estamos seleccionando
    #Podemos navegar entre las etiquetas hermanas (las que están al mismo nivel) con next_sibling y previous_sibling
    summary=scraping.findAll("a")[x+17].parent.next_sibling.next_sibling.get_text()
    #Podemos obtener propiedades específicas de una etiqueta
    link="https://google.com"+str(scraping.findAll("a")[x+17].get('href'))

    return title, summary, link


jsonArray=[]

def getTen(myArr):
    jsonA=[]
    for letra in myArr:
        for x in range(10):
            t,s,l=getGoogle(x,letra.replace(" ","+"))
            jsonA.append({'query':letra, 'title': t, 'summary': s,'link': l})
    return jsonA
def getArray(r,a):
    return np.split(a,3)[r]

#%%
comm = MPI.COMM_WORLD
size=comm.Get_size()
rank=comm.Get_rank()
nodes=3
#%%
array=np.array(['fraude ingreso solidario']*36)
myArray=getArray(rank,array)

jsonArray=getTen(myArray)

########

if rank == 0:
    data=comm.gather(jsonArray,root=0)

if rank==0:
    f=open("googleJSON.json","w")
    
    json.dump(data,f, sort_keys=True, indent=4,ensure_ascii=False)    
    print("Fin")
    f.close()
