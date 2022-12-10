/*
GitFlow Example Project
Nathan Sivewright December 2022
*/

*********************************************************************
******                         MACROS                       *********
*********************************************************************

*******************************
**     General Globals       **
*******************************

global ONEDRIVE "C:\Users\/`c(username)'\C4ED\"
global date = string(date("`c(current_date)'","DMY"),"%tdNNDD")
global time = string(clock("`c(current_time)'","hms"),"%tcHHMMSS")
global datetime = "$date"+"$time"

*******************************
** Project Specific Globals  **
*******************************
global wd "C:\Users\NathanSivewright\Documents\GitHub\Sample-Evaluation" // Working Directory - can I get this generalisable?
global sctodo "import_malawi_ifc_live2"

*********************************************************************
******                 CREATE EXPORT DIRECTORY              *********
*********************************************************************
capture mkdir "$ONEDRIVE\C4ED Global - Documents\10_Knowledge Management\02_KM_All\05_GitFlow\raw"

*********************************************************************
******                 RUN SURVEY CTO DO-FILE               *********
*********************************************************************
do ${wd}\/${sctodo}.do


