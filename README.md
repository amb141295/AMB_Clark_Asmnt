# ClarkAssignment
Step 1: Created the objects and fields as stated in the requirement document.<br/>
Step 2: Cheked for any OOB features that can be used to implement a part of/whole requirement. Example: Dynamic related list in the FlexiPage.<br/>
Step 3: Planned for the component architecture:<br/>
        1. Decided to use the generic table component that I had worked upon in past for this, but with some additional twicks.<br/>
        2. For cross component communication which seemed to be necessary as the Case Config cmp needed to be dynamic, looked into the Lightning message channel documentation as I had not used that before.<br/>
Step 4: Completed the Available configs component and tested its pagination, sort and select fuctionalities.<br/>
Step 5: Completed the Case config component basic UI with the help of generic data table component.<br/>
Step 6: Completed the add functionality for Configs component and introduced the LMS on both the components as publisher and subscriber respectively.<br/>
Step 7: Performed unit testing.<br/>
Step 8: Prepared test class with 88%(AvailableConfigsController) and 87%(CaseConfigsController) coverage.<br/>
Step 9: Cretaed a repo and pushed to repository.<br/>
Step 10: Created a recording for explaining the overall functionality.<br/>
        
        
#Learnings:
1. As per HTML5 Salesforce had to update the behavior of Booloean properties and the way their value is set. Since Winter 16 the boolean property if mentioned in the attributes is considered with the value true, so no need to specify value explicitly. If the boolean property is not mentioend in the attribuutes it means value will be considered as false. Example: hide-checkbox-col, showPagination attributes.
2. We cannot do callout inside a savepoint context.
