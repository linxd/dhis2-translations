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
require(stringr)
#Set this to suit your needs
setwd("/home//jason/development/dhis2/dhis-2/")
wd<-getwd()
allprops<-dir(wd, pattern = "i18.*\\.properties$", full.names = TRUE, recursive=TRUE)
allprops<-allprops[grepl("src",allprops)]
templates<-allprops[grepl("i18n_global\\.|i18n_module\\.|i18n_app\\.",allprops)]
template.dirs<-gsub("i18n_global\\.properties|i18n_module\\.properties|i18n_app\\.properties","",templates)
#Loop through each template file, identifying duplicate k/v pairs from the templates
#These need to be removed manually. 
#The script will exit when a duplicate k/v pair is encountered, and show the name of the offending file
  for (i in 1:length(template.dirs) ) {
    #Start to loop through each template directory
    this.template.file<-templates[i]
    con <- file(this.template.file, "r", blocking = FALSE)
    template<-readLines(con)
    close(con)
    template<-template[grepl("=",template)]
    template<-as.data.frame(str_split_fixed(template,"=",2))
    names(template)<-c("key","value_template")
    if (Reduce("|",duplicated(template$key))) { print(templates[i]); break()}
  }