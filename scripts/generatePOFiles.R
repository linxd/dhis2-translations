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

wd<-setwd("/home//jason/development/dhis2/dhis-2/")

allprops<-dir(wd, pattern = "i18.*\\.properties$", full.names = TRUE, recursive=TRUE)
allprops<-allprops[grepl("src",allprops)]
templates<-allprops[grepl("i18n_global\\.|i18n_module\\.|i18n_app\\.",allprops)]
template.dirs<-gsub("i18n_global\\.properties|i18n_module\\.properties|i18n_app\\.properties","",templates)

translations_files<-list.files(wd, pattern = "^i18.*\\_[a-zA-Z]{2}.properties$", full.names = TRUE, recursive=TRUE)
#Extract the last part
foo<-strsplit(translations_files,"/")
bar<-rep("",length(foo))
for (i in 1:length(foo)){
  bar[i]<-foo[[i]][length(foo[[i]])] }

bar<-gsub("i18n_(app_|module_|global_)","",bar)
bar<-gsub("\\.properties","",bar)
all_langs<-unique(bar)

trans_files<-data.frame(path=translations_files,lang=bar)

#Create some modules names from the 

modules<-strsplit(template.dirs,"/")
modules_is_module<-lapply(modules,function(x) grepl("dhis-",x))
modules_is_module<-lapply(modules_is_module,function(x) max(which(x)))
modules_name<-rep("",length(modules))
for (i in 1:length(modules)) {
  modules_name[i]<-modules[[i]][modules_is_module[[i]]]}

modules<-data.frame(name=modules_name,path=template.dirs,template=templates)

#Create all module directories
setwd("/home//jason/development/dhis2-translations/")
for (i in 1:nrow(modules))
{
  this_dir<-paste0(getwd(),"/",modules$name[i])
  dir.create(this_dir)
  
}
#Initalize the POT file

for (i in 1:nrow(modules)) {
  this_cmd<-paste0("prop2po -P ",modules$template[i]," ", getwd(), "/", modules$name[i], "/", "en.pot")
  system(this_cmd)
}

#Create the po files for each language and module

for (i in 1:nrow(modules)) {
  for (j in 1:length(all_langs)){
  #Get the existing language file if it exists
  this_trans_file<-list.files(as.character(modules$path[i]),
             pattern=paste0("^i18n.+",all_langs[j],"\\.properties"),
             full.names=TRUE)
  if (length(this_trans_file != 0)) {
  this_cmd<-paste0("prop2po --duplicates=msgctxt -t ", modules$template[i], " ",this_trans_file, " ",modules$name[i],"/",all_langs[j],".po") }
  else { this_cmd<-paste0("prop2po ",modules$template[i], " ",modules$name[i],"/",all_langs[j],".po")}
  system(this_cmd)
  }
  
}
