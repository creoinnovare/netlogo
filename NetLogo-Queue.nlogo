;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Modeling Task Scheduling Problems using Multi-Agent Based Simulation System - a heurictic
;; approaches
;;
;; Steven Chen and Andrew Tang
;; Los Alamos Middle School
;; Los Alamos, New Mexico 87544, USA
;; 04/2012
;;
;; This NetLogo simulation project is for the 2012 New Mexico Supercomputing Challenge
;;
;; Using NetLogo release 4.1.3 & NetLogo 5.0.1
;;
;;
;; Task scheduling problem is a hard problem. Where an exhaustive search for an optimal
;; solution is impractical, we choose heuristic methods to speed up the process of finding a
;; satisfactory solution.
;;
;; We have implemented five different heuristic scheduling methods
;; 1 - Round-Robin : This is a fair-shared approach. We let each machine take turn to
;; receive an arriving task. Round-robin scheduling is simple, easy to
;; implement, and starvation-free.
;; The name of the algorithm comes from the round-robin principle known from
;; other fields, where each machine takes an equal share of responsibility to
;; run a task in turn.
;;
;; 2 - Random Selection : A randomized algorithm is an algorithm which employs a degree of
;; randomness as part of its logic. We use the builtin random number generator
;; and decice when machine to run an arriving task.
;; it may not give us a good solution but it is a good indicator when we
;; do the compariatvie studies.
;;
;; 3 - Less Workload First -
;; Each machine keep the total task ececution time assgiend to it.
;; We pick a machine with the least amount total task execution time.
;; We only focus on a specific and continuous time period so tbis heuristic
;; make sense in this simulation. We also expect to a good performance from this
;; heuristic scheduling method.
;;
;; 4 - Early Starting Time First - We can use two different distribution to define a task arrining time, the
;; random (normal distribution) and the randon-poisson (Poisson distribution)
;; We think that we can use the early available to start a task on a machine as the
;; machine selection index. We pick a machine the early starting time to run a
;; task and assign this task to it. We think that this is a reasonable heuristic method. We
;; implemented it in our simulation.
;;
;; 5 - A Mixed Selection - We then come out this interesting heuristic method.
;; We plan to implement four different heuristic scheduling methods. Why not try a
;; combination approach to select an available machine.
;; the idea is to use a random number to decide which method should be used to pick
;; a machine.
;; It is an interesting "demo" to see how good is this mixed method.
;; We called it a heuristic of heuristics.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; We have defined four different agents
;; Task agent - many up to 99999
;; Scheduler agent - one scheduler agent
;; Machine agent - eight machine agents, can be more
;; Decos agent - for random display and decoration only
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Task agent: generate task information -
;; task arriving time, task execution time
;; each task agent sends a task to the scheduler and asks
;; for a machine to run it
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
breed [tasks taskA]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Machine agent
;; each machine keeps its current machine status and waits for
;; a request from the scheduer to run aa assigned taks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
breed [machines machine]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Scheduler agent
;; check is there a arrriving task and find an available
;; machine ro run it
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
breed [schedulers scheduler]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Decos agent
;; this is for decoration only
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
breed [decos deco]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global variables, can be accessed by all agents
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
globals [
totalMachineReserved
numMachineOccupied
numMachineAvailable
waitingTime
idleTime
averageIdleTime
arrivingTime
taskExecTime
finishedJobs
lengthJob
markSpan
numJobCreated
numJobFinished
totalJobs
totalTime
wallClock
throughPut
averageTurnAroundTime
totalTurnAroundTime
utilization
averageResponseTime
averageWaitTime
averageTaskLengthTask
numJobArrived
numJobWaiting
autoTuneTickCount
nextautoTuneTickCount
FlagAutoTune
;; Load Balance Performance Index
LBPI1
LBPI2
LBPI3
LBPI4
;; machine workload information
machWorkLoad1
machWorkLoad2
machWorkLoad3
machWorkLoad4
machWorkLoad5
machWorkLoad6
machWorkLoad7
machWorkLoad8
machWorkLoad9
machWorkLoad10
machWorkLoad11
machWorkLoad12
machWorkLoad13
machWorkLoad14
machWorkLoad15
machWorkLoad16
lessWorkloadMachineID
averageTaskLengthMachine
;; performance data
maxStartTime
minStartTime
maxFinishTime
minFinishTime
maxThroughput
minThroughput
maxTaskLength
minTaskLength
maxUtilization
minUtilization
maxStartTime2
minStartTime2
maxFinishTime2
minFinishTime2
maxThroughput2
minThroughput2
maxTaskLength2
minTaskLength2
maxUtilization2
minUtilization2
loadBalanceIndex
maxJobWait
minJobWait
maxJobFinish
minJobFinish
maxJobWait2
minJobWait2
maxJobFinish2
minJobFinish2
jobPatterns
numJobTick
throughPutTimeTick
selectedMethod
]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; only task agent can access its own variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tasks-own [
  taskID
  taskLength
  arriveTime
  startTime
  finishTime
  waitTime
  markSpanTime
  assignedMachine
  taskDone
  taskWaiting
  taskExecution
  taskFinish
  turnAroundTime
]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; only the scheduler agent can access these variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
schedulers-own [
  schedulerID
  numJobArrive
  numJobStart
  numJobFinish
  numJobWait
  currentmachineID
]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; each machine can access its own variables
;; there is no array ro multi-dimension data structure
;; but this is useful. Each agent can define its own variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
machines-own [
  machineID
  numJobArrive
  numJobStart
  numJobFinish
  numJobWait
  waitTimeM
  idleTimeM
  currentStartTime
  nextAvailTime
  totalTaskTime
  currentTaskID
  utilizationM
  totalTurnAroundTimeM
  averageTurnAroundTimeM
  throughputM
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; the "setup" button"
;; use this "setup" button before run each simulation
;; after the "setup" also you need to select distribution
;; method and scheduling method
;; default is set to
;; normal distribution and round-robin scheduling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup
;; (for this model to work with NetLogo's new plotting features,
;; __clear-all-and-reset-ticks should be replaced with clear-all at
;; the beginning of your setup procedure and reset-ticks at the end
;; of the procedure.)
__clear-all-and-reset-ticks ;; this will clean out all button variables and plot areas
init-globals ;; initialize global variables
;; create one scheduler
;; turtle 0 : schedule
create-schedulers 1
;; create eight machines
;; turtle 1-8: machines
create-machines 8
;; create two watchdog turtles for some extra activities
;; turtle ID 9 adn 10
cro 2
;; create task list
;; we used 100 tasks here for
;; it can be change to different number latermaxNumJobs
;; ID 11 - 110 remap to task ID 1 - 100
create-tasks maxNumJobs
set numJobCreated maxNumJobs
create-decos 100 ;; decoration only
;; setup basic information for agents
setup-scheduler
setup-machines
setup-task-info
output-print "Task Size Range - 0 to "
output-print maxTaskSize
output-print "Total Number of Jobs Created"
output-print maxNumJobs
output-print "Task Arriving Time Between 0 to "
output-print maxJobArriveTime
output-print "Number of machine used in simulation"
output-print numMachine
;; reset the tick counter value to zero
reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; setup schedule basic information
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup-scheduler
ask scheduler 0 [
;;print "scheduler setup done"
set schedulerID 0
set numJobArrive 0
set numJobStart 0
set numJobFinish 0
set numJobWait 0
set currentMachineID 0
]
ask patches [
set pcolor green
]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; initialize global variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to init-globals
set numMachine 8
set totalMachineReserved 8
set numMachineOccupied 0
set numMachineAvailable 0
set waitingTime 0
set idleTime 0
set averageIdleTime 0
set arrivingTime 0
set taskExecTime 0
set finishedJobs 0
set lengthJob 0
set markSpan 0
set totalJobs 0
set numJobFinished 0
set totalTime 0
set wallClock 0
set throughPut 0
set averageTurnAroundTime 0
set totalTurnAroundTime 0
set utilization 0
set averageResponseTime 0
set averageWaitTime 0
set numJobArrived 0
set numJobFinished 0
set numJobWaiting 0
set machWorkLoad1 0
set machWorkLoad2 0
set machWorkLoad3 0
set machWorkLoad4 0
set machWorkLoad5 0
set machWorkLoad6 0
set machWorkLoad7 0
set machWorkLoad8 0
set machWorkLoad9 0
set machWorkLoad10 0
set machWorkLoad11 0
set machWorkLoad12 0
set machWorkLoad13 0
set machWorkLoad14 0
set machWorkLoad15 0
set machWorkLoad16 0
set throughPutTimeTick 0
set lessWorkloadMachineID 0
set maxStartTime 0
set minStartTime 0
set maxFinishTime 0
set minFinishTime 0
set maxThroughput 0
set minThroughput 0
set maxTaskLength 0
set minTaskLength 0
set maxUtilization 0
set minUtilization 0
set maxJobWait 0
set minJobWait 0
set maxJobFinish 0
set minJobFinish 0
set maxStartTime2 0
set minStartTime2 0
set maxFinishTime2 0
set minFinishTime2 0
set maxThroughput2 0
set minThroughput2 0
set maxTaskLength2 0
set minTaskLength2 0
set maxUtilization2 0
set minUtilization2 0
set maxJobWait2 0
set minJobWait2 0
set maxJobFinish2 0
set minJobFinish2 0
set autoTuneTickCount 0
set FlagAutoTune 1
set LBPI1 0
set LBPI2 0
set LBPI3 0
set LBPI4 0
set numJobTick 0
set selectedMethod 1
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; setup resource machine infor
;;; we have used 8 machines in this simulation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup-machines
ask machine 1 [
set machineID 1
set numJobArrive 0
set numJobStart 0
set numJobFinish 0
set numJobWait 0
set currentStartTime 0
set nextAvailTime 0
set currentTaskID 0
set idleTimeM 0
set waitTimeM 0
set utilizationM 0
set totalTaskTime 0
set averageTurnAroundTimeM 0
set totalTurnAroundTimeM 0
]
ask machine 2 [
set machineID 2
set numJobArrive 0
set numJobStart 0
set numJobFinish 0
set numJobWait 0
set currentStartTime 0
set nextAvailTime 0
set currentTaskID 0
set idleTimeM 0
set waitTimeM 0
set utilizationM 0
set totalTaskTime 0
set averageTurnAroundTimeM 0
set totalTurnAroundTimeM 0
]
ask machine 3 [
set machineID 3
set numJobArrive 0
set numJobStart 0
set numJobFinish 0
set numJobWait 0
set currentStartTime 0
set nextAvailTime 0
set currentTaskID 0
set idleTimeM 0
set waitTimeM 0
set utilizationM 0
set totalTaskTime 0
set averageTurnAroundTimeM 0
set totalTurnAroundTimeM 0
]
ask machine 4 [
set machineID 4
set numJobArrive 0
set numJobStart 0
set numJobFinish 0
set numJobWait 0
set currentStartTime 0
set nextAvailTime 0
set currentTaskID 0
set idleTimeM 0
set waitTimeM 0
set utilizationM 0
set totalTaskTime 0
set averageTurnAroundTimeM 0
set totalTurnAroundTimeM 0
]

ask machine 5 [
set machineID 5
set numJobArrive 0
set numJobStart 0
set numJobFinish 0
set numJobWait 0
set currentStartTime 0
set nextAvailTime 0
set currentTaskID 0
set idleTimeM 0
set waitTimeM 0
set utilizationM 0
set totalTaskTime 0
set averageTurnAroundTimeM 0
set totalTurnAroundTimeM 0
]
ask machine 6 [
set machineID 6
set numJobArrive 0
set numJobStart 0
set numJobFinish 0
set numJobWait 0
set currentStartTime 0
set nextAvailTime 0
set currentTaskID 0
set idleTimeM 0
set waitTimeM 0
set utilizationM 0
set totalTaskTime 0
set averageTurnAroundTimeM 0
set totalTurnAroundTimeM 0
]
ask machine 7 [
set machineID 7
set numJobArrive 0
set numJobStart 0
set numJobFinish 0
set numJobWait 0
set currentStartTime 0
set nextAvailTime 0
set currentTaskID 0
set idleTimeM 0
set waitTimeM 0
set utilizationM 0
set totalTaskTime 0
set averageTurnAroundTimeM 0
set totalTurnAroundTimeM 0
]

ask machine 8 [
set machineID 8
set numJobArrive 0
set numJobStart 0
set numJobFinish 0
set numJobWait 0
set currentStartTime 0
set nextAvailTime 0
set currentTaskID 0
set idleTimeM 0
set waitTimeM 0
set utilizationM 0
set totalTaskTime 0
set averageTurnAroundTimeM 0
set totalTurnAroundTimeM 0
]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; let each task agent to create a job
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup-task-info
ask tasks [
;; Task ID
set taskID random maxTaskSize
set tasklength random maxTaskSize
if taskLength = 0 [
set taskLength 1
]
;; task arriving time generated from the selecting
;; distribution
;; the default is normal distribution
if jobPatterns = 0 [
set arriveTime random maxJobArriveTime
]
;; Poisson distribution is used if you select this one
if jobPatterns = 1 [
set arriveTime random-poisson maxJobArriveTime
]
set startTime 0
set finishTime 0
set waitTime 0
set markspanTime 0
set assignedMachine 0
set taskDone 0
set taskWaiting 0
set taskExecution 0
set taskFinish 0
set turnAroundTime 0
;;;;print "tasks setup done"
]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; button to select the Normal distribution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to normalDistribution
set jobPatterns 0
output-print "Select Normal distribution"
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; button to select the Poisson distribution
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to poissonDistribution
set jobPatterns 1
output-print "Select Poisson distribution"
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; button to select the Round-robin scheduling method
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to roundRobin
set selectedMethod 1
output-print "Select Round Robin Method"
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; button to select the Random machine scheduling method
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to randomMethod
set selectedMethod 2
output-print "Select Random Selection Method"
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; button to select the Less Workload First scheduling method
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to lessWorkloadFirst
set selectedMethod 3
output-print "Select Less Workload First Method"
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; button to select the Early Starting Time First scheduling method
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to earlyStartTimeFirst
set selectedMethod 4
output-print "Select Early Starting Time First Method"
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; button to randomly select from the four heuristic methods
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to cockTailMixed
  set selectedMethod 5
  output-print "Select Mixed Heutistic Method"
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; get how many tasks has assigned to a machine at this time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to get-machine-workload-number-of-jobs
ask machine 1 [
set machWorkLoad1 numJobArrive
;;;;print (word "machWorkLoad1 " machWorkLoad1)
]
ask machine 2 [
set machWorkLoad2 numJobArrive
;;;;print (word "machWorkLoad2 " machWorkLoad2)
]
ask machine 3 [
set machWorkLoad3 numJobArrive
;;;;print (word "machWorkLoad3 " machWorkLoad3)
]
ask machine 4 [
set machWorkLoad4 numJobArrive
;;;;print (word "machWorkLoad4 " machWorkLoad4)
]
ask machine 5 [
set machWorkLoad5 numJobArrive
;;;;print (word "machWorkLoad5 " machWorkLoad5)
]
ask machine 6 [
set machWorkLoad6 numJobArrive
;;;;print (word "machWorkLoad6 " machWorkLoad6)
]
ask machine 7 [
set machWorkLoad7 numJobArrive
;;;;print (word "machWorkLoad7 " machWorkLoad7)
]
ask machine 8 [
set machWorkLoad8 numJobArrive
;;;;print (word "machWorkLoad8 " machWorkLoad8)
]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; get what is the current early time to start a task on this machine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to get-machine-early-start-time-first
ask machine 1 [
set machWorkLoad1 nextAvailTime
;;print (word "ESTF machWorkLoad1 " machWorkLoad1)
]
ask machine 2 [
set machWorkLoad2 nextAvailTime
;;print (word "ESTF machWorkLoad2 " machWorkLoad2)
]
ask machine 3 [
set machWorkLoad3 nextAvailTime
;;print (word "ESTF machWorkLoad3 " machWorkLoad3)
]
ask machine 4 [
set machWorkLoad4 nextAvailTime
;;print (word "ESTF machWorkLoad4 " machWorkLoad4)
]
ask machine 5 [
set machWorkLoad5 nextAvailTime
;;print (word "ESTF machWorkLoad5 " machWorkLoad5)
]
ask machine 6 [
set machWorkLoad6 nextAvailTime
;;print (word "ESTF machWorkLoad6 " machWorkLoad6)
]
ask machine 7 [
set machWorkLoad7 nextAvailTime
;;print (word "ESTF machWorkLoad7 " machWorkLoad7)
]
ask machine 8 [
set machWorkLoad8 nextAvailTime
;;print (word "ESTF machWorkLoad8 " machWorkLoad8)
]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; get the current workload on each machine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to get-machine-workload-less-job-first
ask machine 1 [
set machWorkLoad1 totalTaskTime
;;;;print (word "machWorkLoad1 " machWorkLoad1)
]
ask machine 2 [
set machWorkLoad2 totalTaskTime
;;;;print (word "machWorkLoad2 " machWorkLoad2)
]
ask machine 3 [
set machWorkLoad3 totalTaskTime
;;;;print (word "machWorkLoad3 " machWorkLoad3)
]
ask machine 4 [
set machWorkLoad4 totalTaskTime
;;;;print (word "machWorkLoad4 " machWorkLoad4)
]
ask machine 5 [
set machWorkLoad5 totalTaskTime
;;;;print (word "machWorkLoad5 " machWorkLoad5)
]
ask machine 6 [
set machWorkLoad6 totalTaskTime
;;;;print (word "machWorkLoad6 " machWorkLoad6)
]
ask machine 7 [
set machWorkLoad7 totaltaskTime
;;;;print (word "machWorkLoad7 " machWorkLoad7)
]
ask machine 8 [
set machWorkLoad8 totalTaskTime
;;;;print (word "machWorkLoad8 " machWorkLoad8)
]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; get the machineID with the less workload at this time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to get-less-workload-machine
let workload 9999999
if numMachine >= 1 [
if workload > machWorkLoad1 [
set workload machWorkLoad1
set lessWorkloadMachineID 1
]
]
if numMachine >= 2 [
if workload > machWorkLoad2 [
set workload machWorkLoad2
set lessWorkloadMachineID 2
]
]
if numMachine >= 3 [
if workload > machWorkLoad3 [
set workload machWorkLoad3
set lessWorkloadMachineID 3
]
]
if numMachine >= 4 [
if workload > machWorkLoad4 [
set workload machWorkLoad4
set lessWorkloadMachineID 4
]
]
if numMachine >= 5 [
if workload > machWorkLoad5 [
set workload machWorkLoad5
set lessWorkloadMachineID 5
]
]
if numMachine >= 6 [
if workload > machWorkLoad6 [
set workload machWorkLoad6
set lessWorkloadMachineID 6
]
]
if numMachine >= 7 [
if workload > machWorkLoad7 [
set workload machWorkLoad7
set lessWorkloadMachineID 7
]
]
if numMachine >= 8 [
if workload > machWorkLoad8 [
set workload machWorkLoad8
set lessWorkloadMachineID 8
]
]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; get the machine ID taht has the early task starting time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to get-early-start-time-machine
let workload 9999999
if numMachine >= 1 [
if workload > machWorkLoad1 [
set workload machWorkLoad1
set lessWorkloadMachineID 1
]
]
if numMachine >= 2 [
if workload > machWorkLoad2 [
set workload machWorkLoad2
set lessWorkloadMachineID 2
]
]
if numMachine >= 3 [
if workload > machWorkLoad3 [
set workload machWorkLoad3
set lessWorkloadMachineID 3
]
]
if numMachine >= 4 [
if workload > machWorkLoad4 [
set workload machWorkLoad4
set lessWorkloadMachineID 4
]
]
if numMachine >= 5 [
if workload > machWorkLoad5 [
set workload machWorkLoad5
set lessWorkloadMachineID 5
]
]
if numMachine >= 6 [
if workload > machWorkLoad6 [
set workload machWorkLoad6
set lessWorkloadMachineID 6
]
]
if numMachine >= 7 [
if workload > machWorkLoad7 [
set workload machWorkLoad7
set lessWorkloadMachineID 7
]
]
if numMachine >= 8 [
if workload > machWorkLoad8 [
set workload machWorkLoad8
set lessWorkloadMachineID 8
]
]
;;;print (word "select lessworkload machine " lessWorkloadMachineID )
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; randomly select a machine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to get-random-machine
let LnumMachine numMachine + 1
set lessWorkloadMachineID random LnumMachine
if lessWorkloadMachineID = 0 [
set lessWorkloadMachineID random LnumMachine
if lessWorkloadMachineID = 0 [
set lessWorkloadMachineID random LnumMachine
if lessWorkloadMachineID = 0 [
set lessWorkloadMachineID random LnumMachine
if lessWorkloadMachineID = 0 [
set lessWorkloadMachineID 1
]
]
]
]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; use the rounc-robin heuristic to select a machine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to get-round-robin-machine
;;this is Round-robin scheduling heuristic
if currentMachineID = numMachine [
set currentMachineID 1
]
if currentMachineID < numMachine [
set currentMachineID (currentMachineID + 1)
]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; button - Add a machine during the run time
;; this is an usefuly interactive feature of using the NetLogo
;; we can dynamically add some machine(s) to the task simulation
;; when we find the system is overloaded we can add machines to
;; reduce the task's waiting time and increase the overall task thoughput
;; this is an interesting "demo" feture" to learn the task scheduling
;; concept in operating system
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to AddMachine
if numMachine < 8 [
set numMachine numMachine + 1
]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; button - Remove a machine during the run time
;; this is an usefuly interactive feature of using the NetLogo
;; we can dynamically remove some machine(s) to the task simulation
;; when we find the system is underloaded we can remove machines to
;; save system resouece and still maintain a reasonable performance such as
;; waiting time, throughput, and system utilization
;; this is an interesting "demo" feture" to learn the task scheduling
;; concept in operating system
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to RemoveMachine
if numMachine >= 2 [
  set numMachine numMachine - 1
]
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main control procedures
;; the "go" routine is set as "forever"
;; it will repeat the same executing sequence again and again
;; for each iteration we advance a tick acount to remembet the current
;; wall-clock information
;; the tick counter is used as the wall-clock.
;; we check the tick-count with task arriving time
;; if there is a match we should schedule this task ASAP.
;; becasue of this tick count , we then can generate performance data
;; such as task starting time, task finishing time, throughout, utilization,
;; waiting time...
;; we aslo "setup" a simulation-stop condition
;; that is when the create task number is equal to the number of task scheduled
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go
;; LOCAL variables
let taskScheduled 0
let L2MachineID 0
let LMachineID 0
let idleTimeT 0
let waitTimeT 0
let LtaskLength 0
let LtaskID 0
let LstartTime 0
let LfinishTime 0
let LarriveTime 0
let LpreviousStartTime 0
let LmixedMethod 0
set numJobTick 0
let LselectedMethod 0
set LselectedMethod selectedMethod
let LrrPicked 0
let LwaitTime 0
let LidleTime 0
let LturnAroundTime 0
;;output-print "num of task agetns "
;;output-print maxTaskSize
;; this is a "simulation-stop" condition checking
;; we stop the simuation when all created tasks are scheduled
if numJobCreated = totalJobs [
;;print (word "All generaated task are scheduled")
    if maxFinishTime2 < ticks [
      print (word "All generated tasks are finishing execution ")
      print (word "Simulation End")
      stop
    ]
]

;; Check if there is an arriving task from task agent
;; only the un-scheduled task is picked
;;
;; ***********************************************************************************
ask tasks with [taskDone = 0] [
;; only schedule an available taks that is
;; arriving time is equal to the wall clock
;;
if arriveTime = ticks [ ;; am I ready to be scheduled
set-current-plot "Task Distribution"
plotxy ticks taskLength
set numJobTick numJobTick + 1
set-current-plot "Task Arriving Patterns"
plotxy ticks numJobTick
;;print (word "tick " ticks " task arrive time " arriveTime " length "tasklength)
set taskScheduled 1
set totalJobs totalJobs + 1
set LtaskLength taskLength
set LtaskID taskID
set LarriveTime arriveTime
ask scheduler 0 [ ;; Only one scheduler is using here
;; STEP 001: Selection an available machine based on the
;; selected scheduling method
;; user can select a "scheduling method from the button"
;; I have implemented five different heuristic scheduling methods
;; 1 - round-robin
;; 2 - random slection
;; 3 - lett workload first
;; 4 - early starting time first
;; 5 - a mixed selection of the above four heuristic method
;;
;; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; First method: round robin or fail shared method
if LselectedMethod = 1 [
;;get-round-robin-machine
  if currentMachineID = numMachine [
  set currentMachineID 1
;;;;print (word "HBHBHB 001 >>>> " currentMachineID)
  set LrrPicked 1
  ]
if currentMachineID < numMachine [
  if LrrPicked = 0 [
  set currentMachineID currentMachineID + 1
;;;;print (word "HBHBHB 002 >>>> " currentMachineID)
  ]
]
if LrrPicked = 1 [
  set LrrPicked 0
  ]
]
;; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; Second method: randomly selecting a machine to run this task
if LselectedMethod = 2 [
  get-random-machine
  set currentMachineID lessWorkloadMachineID
]
;; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; Third method: Select a machei with less accumulated workload
if LselectedMethod = 3 [
  get-machine-workload-less-job-first
  get-less-workload-machine
  set currentMachineID lessWorkloadMachineID
]
;; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; Fourth method: Select a machienthe with early starting time that can run this taks
if LselectedMethod = 4 [
  get-machine-early-start-time-first
  get-early-start-time-machine
  set currentMachineID lessWorkloadMachineID
]
;; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; Fifth method: This is a mixed selection fo the above four heuristice methods
;; this is an experiment
if LselectedMethod = 5 [
;; use a random number to decide which method is going to select the next machine
set LmixedMethod random 4
if LmixedMethod = 0 [
;;get-round-robin-machine
if currentMachineID = numMachine [
set currentMachineID 1
set LrrPicked 1
]
if currentMachineID < numMachine [
if LrrPicked = 0 [
set currentMachineID currentMachineID + 1
]
]
if LrrPicked = 1 [
set LrrPicked 0
]
]
if LmixedMethod = 1 [
get-random-machine
set currentMachineID lessWorkloadMachineID
]
if LmixedMethod = 2 [
get-machine-workload-less-job-first
get-less-workload-machine
set currentMachineID lessWorkloadMachineID
]
if LmixedMethod = 3 [
get-machine-early-start-time-first
get-early-start-time-machine
set currentMachineID lessWorkloadMachineID
]
]
;; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; set local variables
set LMachineID currentMachineID
set L2MachineID currentMachineID
let MID currentMachineID
;; STEP 002: Assign this task to this selected machine
;; and update information of this machine
ask machine currentMachineID [
set numJobArrive numJobArrive + 1
set numJobStart numJobStart + 1
set numJobFinish numJobFinish + 1
set totalTaskTime totalTaskTime + LtaskLength
set LpreviousStartTime currentStartTime
if nextAvailTime < LarriveTime [
;;print "nextAvailTime < LarriveTime ---------------"
set currentStartTime LarriveTime
set LidleTime LarriveTime - nextAvailTime
set idleTimeM idleTimeM + LidleTime
;;print (word "0002A Machine currentStartTime " currentStartTime " task arrive time " LarriveTime " nextAvailTime " nextAvailTime)
]
if nextAvailTime > LarriveTime [
;;print "nextAvailTime < LarriveTime ---------------"
set currentStartTime nextAvailTime
set LwaitTime nextAvailTime - LarriveTime
set waitTimeM waitTimeM + LwaitTime
;;print (word "0002B Machine currentStartTime " currentStartTime " task arrive time " LarriveTime " nextAvailTime " nextAvailTime)
]
set nextAvailTime currentStartTime + LtaskLength
set LstartTime LpreviousStartTime
set LfinishTime nextAvailTime
set currentTaskID LtaskID
set-current-plot "TaskAction-StartTime"
plotxy LMachineID * 3 LstartTime
;;
set-current-plot "TaskAction-FinishTime"
plotxy LMachineID * 2 LfinishTime
set-current-plot "Num of Job Assigned"
let AverageThroughPut 0
let tplot-flag 0
set tplot-flag ticks mod 100
plotxy LMachineID * 3 numJobFinish
];; end of ask machine
];; end of ask scheduler
set finishTime LfinishTime
set waitTime LwaitTime
set turnAroundTime LfinishTime - LarriveTime
set LturnAroundTime turnAroundTime
set assignedMachine L2MachineID
ask machine L2MachineID [
set totalTurnAroundTimeM totalTurnAroundTimeM + LturnAroundTime
if numJobFinish > 0 [
set averageTurnAroundTimeM totalTurnAroundTimeM / numJobFinish
]
;;print (word "machine totalTaskTime " L2MachineID " totalTaskTime " totalTaskTime " nextAvailTime " nextAvailTime)
set-current-plot "Total Task Execution Time"
plotxy L2MachineID * 2 totalTaskTime
;; plotxy L2MachineID * 3 totalTaskTime
if nextAvailTime > 0 [
if totalTaskTime > nextAvailTime [
;;print (word "totalTaskTime > nextAvailTime " totalTaskTime " > " nextAvailTime " How could this happen?")
]
if nextAvailTime > 0 [
set utilizationM totalTaskTime / nextAvailTime
]
set-current-plot "Utilization"
;;clear-plot
plotxy L2MachineID * 2 utilizationM
;; plotxy L2MachineID * 3 utilizationM
;;print (word "machine totalTaskTime " L2MachineID " totalTaskTime " totalTaskTime " nextAvailTime " nextAvailTime " utilization " utilizationM)
]
]
set taskDone 1
set finishedJobs finishedJobs + 1
]
] ;; end if ask tasks
;; ***********************************************************************************
;; Check starting time
;; Check execution time
;; check finish time
;; numJobArrive
;; numJobStart
;; numJobFinish
;; numJobWait
;; ***********************************************************************************
let LMachID 0
set LTaskID 0
ask tasks with [taskDone = 1] [
set LMachID assignedMachine
set LTaskID taskID
;;print (word "taskID " taskID " MachineID " LMachID " finishTime " finishTime "global time tick " ticks)
if taskFinish = 0 [ ;; only check if this task is not yet finished : waiting, execution .....
;;print (word "I am not yet finished ")
if finishTime = ticks [ ;; I am finished
;;print (word "I am finished " "finishTime " finishTime "tick " ticks)
set taskExecution 2
set taskWaiting 2
set taskFinish 1
ask machine LMachID [
set numJobFinish numJobFinish + 1
set numJobWait numJobWait - 1
;;print (word " I am finished taskID " LTaskID " numJobWait " numJobWait)
]
;; set taskDone 2
]
if startTime = ticks [ ;; I am ready to be execute
;;print (word "I start execution " "startTime " startTime "tick " ticks)
set taskExecution 1
set taskWaiting 2
ask machine LMachID [
set numJobStart numJobStart + 1
]
]
if startTime < ticks [ ;; I am waiting
if taskWaiting = 0 [
;;print (word "I am waiting " "startTime " startTime "tick " ticks)
set taskWaiting 1
ask machine LMachID [
set numJobWait numJobWait + 1
;;print (word " am waiting taskID " LTaskID " numJobWait " numJobWait)
]
]
]
]
]
;; end of ask tasks taskdone = 1
;; *******************************************************************************
set totalTurnAroundTime totalTurnAroundTime + LturnAroundTime
if finishedJobs > 0 [
set averageTurnAroundTime totalTurnAroundTime / finishedJobs
]
let plot-flag 0
set plot-flag ticks mod 10
if plot-flag = 0 [
if taskScheduled = 1 [
;;setup-task-info
ask machines [
set shape "house"
set color yellow
right random 360
forward 1
set-current-plot "machine"
plotxy random 1 random 1
]
ask schedulers [
set shape "car"
set color green
right random 360
forward 2
set-current-plot "machine"
plotxy random 1 random 1
]
ask decos [
;;ask tasks [
set shape "person"
set color white
right random 360
forward 3
set-current-plot "machine"
plotxy random 1 random 1
]
]
]
set totalTime sum [totalTaskTime] of machines
if numMachine > 0 [
set averageTaskLengthMachine totalTime / numMachine
]
set throughPut sum [numJobFinish] of machines
if numMachine > 0 [
set throughPut throughPut / numMachine
]
if taskScheduled = 1 [
set numJobFinished numJobFinished + 1
set averageTaskLengthTask totalTime / numJobFinished
]
set averageWaitTime sum [waitTime] of tasks
if averageWaitTime > 0 [
set averageWaitTime averageWaitTime / totalJobs
set-current-plot "WaitTime"
plotxy ticks averageWaitTime
]
;;
;; Auto Tuning operation if enable
;; add a machine when the waittile is too long
;; remove a machine whe the waiting time below minWaitTimeAllow
;;
if numMachine > 0 [
if FlagAutoTune = 1 [
;;print (word "FlagAutoTune is 1")
if averageWaitTime > maxWaitTimeAllow [
set autoTuneTickCount ticks
set nextautoTuneTickCount ticks + maxWaitTimeAllow
if numMachine < 8 [
set numMachine numMachine + 1
set FlagAutoTune 0
print (word "add one machine ")
output-print "System is overloaded! Add one more machine to service"
;;print (word "reset FlagAutoTune to 0")
set-current-plot "TaskAction-StartTime"
clear-plot
set-current-plot "TaskAction-FinishTime"
clear-plot
set-current-plot "Num of Job Assigned"
clear-plot
set-current-plot "Total task Execution Time"
clear-plot
set-current-plot "Utilization"
clear-plot
]
]
if averageWaitTime < minWaitTimeAllow [
set autoTuneTickCount ticks
set nextautoTuneTickCount ticks + minWaitTimeAllow
if numMachine > 2 [
set numMachine numMachine - 1
set FlagAutoTune 0
print (word "remove one machine ")
output-print "System is underloaded! Remove one more machine from service"
;;print (word "reset FlagAutoTune to 0")
set-current-plot "TaskAction-StartTime"
clear-plot
set-current-plot "TaskAction-FinishTime"
clear-plot
set-current-plot "Num of Job Assigned"
clear-plot
set-current-plot "Total task Execution Time"
clear-plot
set-current-plot "Utilization"
clear-plot
]
]
]
if ticks = nextautoTuneTickCount [
set FlagAutoTune 1
;;print (word "reset FlagAutoTune to 1")
]
if FlagAutoTune = 0 [
;; print (word "FlagAutoTune is 0")
]
]

;;set plot-flag ticks mod 5
set plot-flag 0
if plot-flag = 0 [
set maxStartTime max-one-of machines [ currentStartTime ]
set minStartTime min-one-of machines [ currentStartTime ]
set maxFinishTime max-one-of machines [ nextAvailTime ]
set minFinishTime min-one-of machines [ nextAvailTime ]
set maxThroughput max-one-of machines [ numJobFinish ]
set minThroughput min-one-of machines [ numJobFinish ]
set maxTaskLength max-one-of machines [ totalTaskTime ]
set minTaskLength min-one-of machines [ totalTaskTime ]
set maxUtilization max-one-of machines [ utilizationM ]
set minUtilization min-one-of machines [ utilizationM ]
set maxJobWait max-one-of machines [ numJobWait ]
set minJobWait min-one-of machines [ numJobWait ]
set maxJobFinish max-one-of machines [ numJobFinish ]
set minJobFinish min-one-of machines [ numJobFinish ]
set maxStartTime2 max [ currentStartTime ] of machines
set minStartTime2 min [ currentStartTime ] of machines
set maxFinishTime2 max [ nextAvailTime ] of machines
set minFinishTime2 min [ nextAvailTime ] of machines
set maxThroughput2 max [ numJobFinish ] of machines
set minThroughput2 min [ numJobFinish ] of machines
set maxTaskLength2 max [ totalTaskTime ] of machines
set minTaskLength2 min [ totalTaskTime ] of machines
set maxUtilization2 max [ utilizationM ] of machines
set minUtilization2 min [ utilizationM ] of machines
set maxJobWait2 max [ numJobWait ] of machines
set minJobWait2 min [ numJobwait ] of machines
set maxJobFinish2 max [ numJobFinish ] of machines
set minJobFinish2 min [ numJobFinish ] of machines
set loadBalanceIndex maxTaskLength2 - minTaskLength2
set LBPI1 maxTaskLength2 - minTaskLength2
set LBPI2 maxUtilization2 - minUtilization2
set LBPI3 maxJobFinish2 - minJobFinish2
;;print (word " M " maxJobWait " numJobWait " maxJobWait2)
;;print (word " M " minJobWait " numJobWait " minJobWait2)
;; print (word " M " maxJobWait " numJobWait " maxJobWait2)
;; print (word " M " maxJobWait " numJobWait " maxJobWait2)
set LBPI4 maxJobWait2 - minJobWait2
]
set utilization sum [utilizationM] of machines
;;set utilization utilization / numMachine
if numMachine > 0 [
set utilization utilization / numMachine
]
;; advancing one tick count
tick
end ;; end of GO procedure

@#$#@#$#@
GRAPHICS-WINDOW
27
185
186
345
-1
-1
4.6
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
380
55
515
88
Normal Distribution
normalDistribution
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
31
144
94
177
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
118
144
181
177
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
198
54
370
87
maxTaskSize
maxTaskSize
1
150
85.0
1
1
NIL
HORIZONTAL

SLIDER
199
93
371
126
maxNumJobs
maxNumJobs
1
500
243.0
1
1
NIL
HORIZONTAL

SLIDER
199
132
371
165
maxJobArriveTime
maxJobArriveTime
0
10000
10000.0
100
1
NIL
HORIZONTAL

SLIDER
199
171
371
204
numMachine
numMachine
1
8
2.0
1
1
NIL
HORIZONTAL

SWITCH
199
212
318
245
AutoTuning
AutoTuning
0
1
-1000

SLIDER
198
254
370
287
maxWaitTimeAllow
maxWaitTimeAllow
10
200
80.0
10
1
NIL
HORIZONTAL

SLIDER
197
297
369
330
minWaitTimeAllow
minWaitTimeAllow
10
100
40.0
10
1
NIL
HORIZONTAL

BUTTON
379
96
518
129
Poisson Distribution
poissonDistribution
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
527
57
674
90
Round Robin
roundRobin
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
528
98
674
131
Random
randomMethod
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
528
141
675
174
Early Start First Time
earlyStartTimeFirst
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
528
184
675
217
Less Workload First
lessWorkloadFirst
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
528
228
675
261
Mixed Heuristics
cockTailMixed
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
32
53
180
86
Add One Machine
AddMachine
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
30
95
181
128
Remove One Machine
RemoveMachine
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
17
469
151
514
Max Utillization
maxUtilization
17
1
11

PLOT
1509
433
1709
583
Task Distribution
Ticks
Task Length
0.0
10200.0
0.0
155.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

PLOT
1308
284
1508
434
Utilization
Machines
Utilization (%)
0.0
20.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

PLOT
738
52
1009
270
TaskAction-StartTime
Machines
Task Start Time
0.0
32.0
0.0
10900.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

PLOT
739
274
1010
487
TaskAction-FinishTime
Machines
Task Finish Time
0.0
30.0
0.0
15000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

PLOT
1014
52
1273
269
Task Arriving Patterns
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

PLOT
1276
81
1476
231
Total Task Execution Time
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

PLOT
1015
275
1275
486
Num of Job Assigned
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

PLOT
739
492
1011
724
WaitTime
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

PLOT
1521
110
1721
260
machine
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
