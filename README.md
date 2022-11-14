# FileAuditSystem
Implements files monitor with Apple Endpoint Security framework

<img width="488" alt="image" src="https://user-images.githubusercontent.com/36739214/201655060-81664f5e-b3b8-4929-b0d9-d6b1736a31a7.png">

**Instruction**
1. Install extension 
2. Select directories to monitor. 
3. Do something with files in directory
4. Check working by exporting logs in file

Example of usage: 
https://drive.google.com/file/d/14P43FlVYL2PTfakD0jiNLmoTf-20OwPv/view?usp=sharing

P.S.

Thoughts: 
Solution of this task is not trivial. These are my remarks:
1. Disable SIP. SIP doesn't permit to run programs on mac without special provision files and certificates.
2. C API. Endpoint security framework has C API that unsafer than Swift. It is easier to crash program.
3. Debugging. Debugging of System extension is not available for XCode. The exclusive ways are attaching to an extension process through LLDB CLI or debug logs. 
4. Data sharing. System extensions have own containers in private/var/root that are inaccessible for Apps containers. You should use XPC to communicate between processes. 
5. Complexity of testing. I think System extensions can be tested only with end2end tests. 
6. Project options. Different files like signing, info.plist and entitlements should be configured correctly to run program properly.   
  

Ways to upgrade: 
1. Make realtime monitor with timer scheduler.
2. Ability to export all saved logs
