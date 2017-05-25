#!/usr/bin/env ruby
require 'json'


  start = Time.now.to_f
  templatePath = "#{File.dirname(__FILE__)}/eslint-report-widget.html.erb"

=begin FILE DIFFERENCES RUBY
  #f1 = File.read("/Users/sulemanmalik/Desktop/eslint-kronos.json")
  f1 = File.read("C:\\Users\\suleman.malik\\Desktop\\parser\\web-schedule-eslint.json")
  #f1=File.read("tmp/eslint-reports/eslint-kronos.json")
  f1arr = JSON.parse(f1)

  #f2 = File.read("/Users/sulemanmalik/Desktop/eslint-kronos-2.json")
  f2 = File.read("C:\\Users\\suleman.malik\\Desktop\\eslint-kronos-2.json")
  #f2=File.read("tmp/eslint-reports/eslint-kronos-2.json")
  f2arr = JSON.parse(f2)

  if f1arr != f2arr
    diff= f1arr-f2arr
  end

  fileArr = []
  errorArr =[]

  for i in 0..diff.size-1 do
    fileArr[i]=diff[i]['filePath']
    errorArr[i] = diff[i]['errorCount']
  end

  errorCount1=0
  warningCount1=0

  for i in 0..f1arr.size-1 do
    errorCount1 += f1arr[i]['errorCount']
    warningCount1 += f1arr[i]['warningCount']
  end
  problemCount1 = errorCount1+warningCount1

  errorCount2=0
  warningCount2=0

  for i in 0..f2arr.size-1 do
    errorCount2 += f2arr[i]['errorCount']
    warningCount2 += f2arr[i]['warningCount']
  end
  problemCount2 = errorCount2+warningCount2
=end


  #READING JSON FILE, STORING INTO STRING AND PARSING AS A HASH TABLE
  #jsonStr = File.read("tmp/eslint-reports/eslint-kronos.json")           #USE FOR TEST SERVER
  jsonStr = File.read("C:\\Users\\suleman.malik\\Desktop\\parser\\web-schedule-eslint.json")   #USE FOR LOCAL SERVER

  jsonHash = JSON.parse(jsonStr)

  #CALCULATING SUMMARY OF ERRORS AND WARNINGS
  errorCount=0
  warningCount=0

  for i in 0..jsonHash.size-1 do
    errorCount += jsonHash[i]['errorCount']
    warningCount += jsonHash[i]['warningCount']
  end
  problemCount = errorCount+warningCount



  #CALCULATING TOP ERRORS/WARNINGS FREQUENCY
  #These two strings are going to separate all rule IDs that have severities of 1 (Error) and 2 (Warning)
  errorStr=""
  warningStr=""
  i=0
  k=0

  #Looping through all filePaths from the eslint.json file to separate errors from warnings (Used for summary tables)
  while k<jsonHash.size
    for i in 0..jsonHash[k]['messages'].size-1 do
      if jsonHash[k]['messages'][i]['severity'] == 2
        errorStr += ' ' + jsonHash[k]['messages'][i]['ruleId']
      elsif jsonHash[k]['messages'][i]['severity'] == 1
        warningStr += ' ' + jsonHash[k]['messages'][i]['ruleId']
      end
    end
    k+=1
  end
  errorArray=errorStr.split
  warningArray=warningStr.split

  errorFrequencyHash = errorArray.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
  warningFrequencyHash = warningArray.inject(Hash.new(0)) { |h,v| h[v] +=1; h}

  sortedErrorFrequencyHash = errorFrequencyHash.sort_by{|_key, value| value}
  sortedWarningFrequencyHash = warningFrequencyHash.sort_by {|_key, value| value}

  top5errors = []
  top5warnings = []

  (sortedErrorFrequencyHash.size-1).downto(sortedErrorFrequencyHash.size-5){|x| top5errors << sortedErrorFrequencyHash[x]}
  (sortedWarningFrequencyHash.size-1).downto(sortedWarningFrequencyHash.size-5){|x| top5warnings << sortedWarningFrequencyHash[x]}

  top1Error = top5errors[0][0]
  top2Error = top5errors[1][0]
  top3Error = top5errors[2][0]
  top4Error = top5errors[3][0]
  top5Error = top5errors[4][0]

  top1ErrorFreq = top5errors[0][1]
  top2ErrorFreq = top5errors[1][1]
  top3ErrorFreq = top5errors[2][1]
  top4ErrorFreq = top5errors[3][1]
  top5ErrorFreq = top5errors[4][1]

  top1Warning = top5warnings[0][0]
  top2Warning = top5warnings[1][0]
  top3Warning = top5warnings[2][0]
  top4Warning = top5warnings[3][0]
  top5Warning = top5warnings[4][0]

  top1WarningFreq = top5warnings[0][1]
  top2WarningFreq = top5warnings[1][1]
  top3WarningFreq = top5warnings[2][1]
  top4WarningFreq = top5warnings[3][1]
  top5WarningFreq = top5warnings[4][1]



  #CALCULATING MOST PROBLEMATIC FILES (FILES WITH LARGEST PROBLEM COUNT (ERROR+WARNING COUNT) )
  for p in 0..jsonHash.size-1 do
    jsonHash[p].tap{|hs| hs.delete('messages')}
  end

  arr = []
  for s in 0..jsonHash.size-1 do
    arr << jsonHash[s].merge(problemCount: jsonHash[s]['errorCount']+jsonHash[s]['warningCount'])
  end
  problemHash = arr.sort_by!{|hsh| hsh[:problemCount] }
  problemArray=[]
  (problemHash.size-1).downto(problemHash.size-5){|x| problemArray << problemHash[x]}



  top1ProblemFilePath = problemArray[0]['filePath']
  top2ProblemFilePath = problemArray[1]['filePath']
  top3ProblemFilePath = problemArray[2]['filePath']
  top4ProblemFilePath = problemArray[3]['filePath']
  top5ProblemFilePath = problemArray[4]['filePath']

  top1ProblemErrors = problemArray[0]['errorCount']
  top2ProblemErrors = problemArray[1]['errorCount']
  top3ProblemErrors = problemArray[2]['errorCount']
  top4ProblemErrors = problemArray[3]['errorCount']
  top5ProblemErrors = problemArray[4]['errorCount']

  top1ProblemWarnings = problemArray[0]['warningCount']
  top2ProblemWarnings = problemArray[1]['warningCount']
  top3ProblemWarnings = problemArray[2]['warningCount']
  top4ProblemWarnings = problemArray[3]['warningCount']
  top5ProblemWarnings = problemArray[4]['warningCount']


  finalErrorStr =
      "
  <!DOCTYPE html>
  <head>
     <link rel = 'stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css'>
     <style>
        .summary-table {
        width: 50%;
        }
        .summary-table, .summary-table th, .summary-table td {
        color: #333;
        border: 1px solid #ddd;
        border-collapse: collapse;
        margin: 0;
        }
        .summary-table th {
        color: #444;
        background-color: #fafafa;
        font-weight: 400;
        text-transform: capitalize;
        border-bottom-width: 2px;
        }
        .difference-table, .difference-table th, .difference-table td {
        float:right;
        color: #333;
        border: 1px solid #ddd;
        border-collapse: collapse;
        margin: 0;
        }
        .right{
        float:right;
        }
        .text-success {
        color: #468847;
        }
        .text-warning {
        color: #f0ad4e;
        font-size: 105%;
        font-weight: 500;
        }
        .text-error {
        color: #b94a48;
        font-size: 105%;
        font-weight: 500;
        }
        .text-info{
        color: #000000;
        font-size: 105%;
        font-weight: 500;
        }
        td, th {
        padding: 2px 7px;
        }
        h1 {
        margin: 0;
        }
        th {
        font-weight: 400;
        text-align: left;
        border-bottom: 1px solid #ddd;
        }
        .left{
        float: left;
        }
     </style>
     <script>
        var acc = document.getElementsByClassName('accordion');
        var i;
        for (i = 0; i < acc.length; i++) {
            acc[i].onclick = function() {
                this.classList.toggle('active');
                var panel = this.nextElementSibling;
                if (panel.style.maxHeight){
                    panel.style.maxHeight = null;
                } else {
                    panel.style.maxHeight = panel.scrollHeight + 'px';
                }
            }
        }
     </script>
  </head>
  <body>
     <h1>ESLint Report - </h1> <h2>current analysis</h2>
     <h>#{problemCount} Problems</h> &nbsp; <i class='fa fa-exclamation-circle text-error' aria-hidden='true'></i> Errors: #{errorCount} &nbsp; <i class='fa fa-arrow-circle-up text-warning' aria-hidden='true'></i> Warnings: #{warningCount} <br>
<!--
     <h1 class = 'text-info right'> <i class='fa fa-line-chart' aria-hidden='true'></i> Delta </h1>
     <div class = 'table'>
        <table class='difference-table'>
          <tr>
             <th>Rule</th>
             <th>Count</th>
           </tr>
        </table>
     </div>-->
     <h1 class = 'text-error'> <i class='fa fa-exclamation-circle' aria-hidden='true'></i> Top Errors </h1>
     <div class = 'table'>
        <table class='summary-table'>
           <tr>
              <th>Rule</th>
              <th>Count</th>
           </tr>
           <tr>
              <td><a href='http://eslint.org/docs/rules/#{top1Error}'>#{top1Error}</a></td>
              <td>#{top1ErrorFreq}</td>
           </tr>
           <tr>
              <td><a href='http://eslint.org/docs/rules/#{top2Error}'>#{top2Error}</a></td>
              <td>#{top2ErrorFreq}</td>
           </tr>
           <tr>
              <td><a href='http://eslint.org/docs/rules/#{top3Error}'>#{top3Error}</a></td>
              <td>#{top3ErrorFreq}</td>
           </tr>
           <tr>
              <td><a href='http://eslint.org/docs/rules/#{top4Error}'>#{top4Error}</a></td>
              <td>#{top4ErrorFreq}</td>
           </tr>
           <tr>
              <td><a href='http://eslint.org/docs/rules/#{top5Error}'>#{top5Error}</a></td>
              <td>#{top5ErrorFreq}</td>
           </tr>
        </table>
     </div>
     <br>
     <h1 class = 'text-warning'> <i class='fa fa-arrow-circle-up' aria-hidden='true'></i> Top Warnings </h1>
     <div class = 'table'>
        <table class='summary-table'>
           <tr>
              <th>Rule</th>
              <th>Count</th>
           </tr>
           <tr>
              <td><a href='http://eslint.org/docs/rules/#{top1Warning}'>#{top1Warning}</a></td>
              <td>#{top1WarningFreq}</td>
           </tr>
           <tr>
              <td><a href='http://eslint.org/docs/rules/#{top2Warning}'>#{top2Warning}</a></td>
              <td>#{top2WarningFreq}</td>
           </tr>
           <tr>
              <td><a href='http://eslint.org/docs/rules/#{top3Warning}'>#{top3Warning}</a></td>
              <td>#{top3WarningFreq}</td>
           </tr>
           <tr>
              <td><a href='http://eslint.org/docs/rules/#{top4Warning}'>#{top4Warning}</a></td>
              <td>#{top4WarningFreq}</td>
           </tr>
           <tr>
              <td><a href='http://eslint.org/docs/rules/#{top5Warning}'>#{top5Warning}</a></td>
              <td>#{top5WarningFreq}</td>
           </tr>
        </table>
     </div>
     <br>
     <h1 class = 'text-info'> <i class='fa fa-folder-open' aria-hidden='true'></i> Problematic files </h1>
     <div class = 'table'>
        <table class='summary-table'>
           <tr>
              <th>File Path</th>
              <th>Errors</th>
              <th>Warnings</th>
           </tr>
           <tr bgcolor='#F2DEDE'>
              <td>#{top1ProblemFilePath}</td>
              <td>#{top1ProblemErrors}</td>
              <td>#{top1ProblemWarnings}</td>
           </tr>
           <tr>
              <td>#{top2ProblemFilePath}</td>
              <td>#{top2ProblemErrors}</td>
              <td>#{top2ProblemWarnings}</td>
           </tr>
           <tr>
              <td>#{top3ProblemFilePath}</td>
              <td>#{top3ProblemErrors}</td>
              <td>#{top3ProblemWarnings}</td>
           </tr>
           <tr>
              <td>#{top4ProblemFilePath}</td>
              <td>#{top4ProblemErrors}</td>
              <td>#{top4ProblemWarnings}</td>
           </tr>
           <tr>
              <td>#{top5ProblemFilePath}</td>
              <td>#{top5ProblemErrors}</td>
              <td>#{top5ProblemWarnings}</td>
           </tr>
        </table>
     </div>
     <br>

  </body>
  "
=begin FILE DIFFERENCES HTML

     <h1 class = 'text-info'> <i class='fa fa-line-chart' aria-hidden='true'></i> Delta </h1>
      <p> Previous analysis:<p>
        <ul>
          <li>problems: #{problemCount1}</li>
          <li>warnings: #{warningCount1}</li>
          <li>errors: #{errorCount1}</li>
        </ul>
=end

  File.open(templatePath, "w"){|file| file.write(finalErrorStr)}

  ending = Time.now.to_f

  puts errorCount
  endTime = ending-start

  puts endTime
