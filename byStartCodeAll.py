#!/usr/bin/env python


#from openpyxl import load_workbook
from xlrd import open_workbook
import glob

# header
print "\t".join( ['subj', 'run', 'start', 'target', 'trial', 'count', 'sacc', 'score', 'lat', 'lat?', 'acc', 'acc?', 'note', 'logic']);

# get each spreadsheet
for xlsfile in glob.glob('/Volumes/Connor/bars/data/1*/eye_scoring/fs*.xls'):
   
   # load sheet and extract subject number
   wb   = open_workbook(xlsfile)
   subj = xlsfile.split('/')[5].split('/')[-1]
   run  = xlsfile[-5]

   ws = wb.sheet_by_name('Sheet1')

   for rownum in range(ws.nrows):
       if ws.cell(rownum,0).value in (50,100,200)  and  (ws.cell(rownum,7).value or ws.cell(rownum,9).value):
          print "\t".join(map(str,[subj,run]+ws.row_values(rownum)))
