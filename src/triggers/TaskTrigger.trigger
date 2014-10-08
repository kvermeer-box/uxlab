trigger TaskTrigger on Task (after insert) {

    if (trigger.IsInsert)
    {
        ContactRolesAutoCreate.autoCreateRequestHandler(trigger.newMap);
    }

}