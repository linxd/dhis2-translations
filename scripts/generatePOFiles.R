#Copyright (c) 2015, University of Oslo
#All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# Neither the name of HISP Nordic AB nor the names of its contributors may
# be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
require(plyr)
require(stringr)

source_dir<-"/home/jason/development/dhis2/dhis-2/"
trans_dir<-"/home/jason/development/dhis2-translations/"


allprops<-dir(source_dir, pattern = "i18.*\\.properties$", full.names = TRUE, recursive=TRUE)
allprops<-data.frame(file=allprops[grepl("src",allprops)])
allprops$is_template<-grepl("(i18n_global\\.|i18n_module\\.|i18n_app\\.)(_en)?",allprops$file)
allprops$dir<-gsub("/i.+properties$","/",allprops$file)

props<-allprops[!allprops$is_template,]
templates<-allprops[allprops$is_template,]
props<-merge(props,templates[c("file","dir")],by="dir")

props<-props[,c("dir","file.x","file.y")]
names(props)<-c("dir","prop","template")
#Extract the last part
foo<-strsplit(as.character(props$prop),"/")
bar<-rep("",length(foo))
for (i in 1:length(foo)){
  bar[i]<-foo[[i]][length(foo[[i]])] }

bar<-gsub("i18n_(app_|module_|global_)","",bar)
bar<-gsub("\\.properties","",bar)
props$lang<-bar
all_langs<-unique(bar)


#Create some modules names from the 
modules<-strsplit(as.character(props$dir),"/")
modules_is_module<-lapply(modules,function(x) grepl("dhis-",x))
modules_is_module<-lapply(modules_is_module,function(x) max(which(x)))
modules_name<-rep("",length(modules))
for (i in 1:length(modules)) {
  modules_name[i]<-modules[[i]][modules_is_module[[i]]]}

props$module_name<-modules_name


#Create all module directories and init the POT file

modules<-unique(props[,c("module_name","template")])
for (i in 1:nrow(modules))
{
  this_dir<-paste0(trans_dir,"/",modules$name[i])
  dir.create(this_dir)
  this_cmd<-paste0("prop2po -P ",modules$template[i]," ", trans_dir, "/", modules$name[i], "/", "en.pot")
  system(this_cmd)
  
}


#Create the po files for each language and module

for (i in 1:nrow(props)) {
  po_file<-paste0(trans_dir,"/",props$module_name[i],"/",props$lang[i],".po")
  #If the file does not exist
  if ( !file.exists(po_file) ) {
 this_cmd<-paste0("prop2po ",props$template[i], " ",trans_dir,"/",props$module_name[i],"/",props$lang[i],".po") 
  } else {
  this_cmd<-paste0("prop2po --duplicates=msgctxt -t ", props$template[i], " ",props$prop[i], " ",trans_dir,"/",props$module_name[i],"/",props$lang[i],".po") 
  
  }
 print(this_cmd)
 system(this_cmd)
}