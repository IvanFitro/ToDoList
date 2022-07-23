//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title <ToDoList.sol>
/// @author <IvanFitro>
/// @notice <Creation of a planner that you can add/remove tasks, add/remove assistants to the tasks,
///          put timelines to the tasks, modify the tasks and complete the tasks>

contract ToDoList {

    //State variables
    address owner;
    uint [] tasks;

    struct list {
        uint id;
        bool comp;
        string desc;
        uint date;
        bool isDelete;
        //Mapping to relationate the owner of the task with their assistants
        mapping(address => bool) Allowed;
    }

    //Modifier to comprove the owner
    modifier onlyOwner(uint _id) {
        require(Owner[_id] == msg.sender, "You aren't the owner of the task");
        _;
    }
    //Modifier to see if you have enough time to complet the task
    modifier countTime(uint _id) {
        require(List[_id].date >= block.timestamp, "You don't have enough time");
        _;
    }
    //Modifier to comprove if the task is deleted
    modifier Deleted(uint _id) {
        require(List[_id].isDelete == false, "This task is deleted");
        _;
    }
    

    //Mapping to relationate the id with the task
    mapping (uint => list) public List;
    //Mapping to relationate one person with all of their tasks;
    mapping (address => uint []) allTasks;
    //Mapping to relationate the task with the owner
    mapping (uint => address) Owner;

    //Events
    event newTask (uint, string);
    event taskCompleted (uint);
    event newAssistant (uint, address);
    event modifiedTask (uint);

    //Function to create a task (_date in days)
    function createTask(string memory _desc, uint _date) public  {
        uint _id = tasks.length;
        //Fix the time limit to complet the task (convert the seconds to days)
        uint Date = (block.timestamp + _date * 86400 seconds);
        tasks.push(_id);
        //Add the task to the struct
        List[_id].id = _id;
        List[_id].comp = false;
        List[_id].desc = _desc;
        List[_id].date= Date;
        List[_id].isDelete= false;
        List[_id].Allowed[msg.sender] = true;
        //Add the taks to allTasks
        allTasks[msg.sender].push(_id);
        //Save the owner
        Owner[_id] = msg.sender;
        emit newTask(_id, _desc);
        
    }

    //Function to see all the tasks of a person
    function seeTasks() public view returns(uint [] memory) {
        return allTasks[msg.sender];
    }

    //Function to complet a task
    function Complete(uint _id) public countTime(_id) Deleted(_id)  {
        require(_id <= tasks.length, "This task doesn't exists");
        require(List[_id].Allowed[msg.sender] == true, "You don't have permissions");
        //Complete the task
        List[_id].comp = true;
        emit taskCompleted(_id);
    }

    //Function to add assitants to the task
    function addAssistant(address _assistant, uint _id) public onlyOwner(_id) Deleted(_id) {
        require(_id <= tasks.length, "This task doesn't exists");
        //Let permissions to the assistant
        List[_id].Allowed[_assistant] = true;
        emit newAssistant(_id, _assistant);
    }

    //Function to remove an assistant
    function removeAssistant(address _assistant, uint _id) public onlyOwner(_id) Deleted(_id) returns(bool) {
        //Comprove that you have an assistant in this task
        require(List[_id].Allowed[msg.sender] == true, "You don't have assistants in this task");
        List[_id].Allowed[_assistant] = false;
        return true;
    }

    //Function to modify the date of a task
    function modifyDate(uint _id, uint _newDate) public onlyOwner(_id) countTime(_id) Deleted(_id){
        List[_id].date = (block.timestamp + _newDate * 86400 seconds);
        emit modifiedTask(_id);
    }

    //Function to modify the description of a task
    function modifyDesc(uint _id, string memory _newDesc) public onlyOwner(_id) Deleted(_id) {
        List[_id].desc = _newDesc;
        emit modifiedTask(_id);
    }

    //Function to delete the task (_position is the position in the array, not the id of the task)
    function deleteTask(uint _position) public onlyOwner(_position) countTime(_position) {
        //Put the selected id to the last position to remove
        allTasks[msg.sender][_position] = allTasks[msg.sender][allTasks[msg.sender].length - 1];
        allTasks[msg.sender].pop();
        //Delete the task
        List[_position].isDelete = true;
        
        
    }

    //Function to see how much time you have left (in hours)
    function seeTimeLeft(uint _id) public view Deleted(_id) returns(uint)  {
        return((List[_id].date - block.timestamp)/3600);
    }
}