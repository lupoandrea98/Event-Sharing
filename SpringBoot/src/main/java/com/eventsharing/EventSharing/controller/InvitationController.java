package com.eventsharing.EventSharing.controller;

import com.eventsharing.EventSharing.DTO.DTOInvitation;
import com.eventsharing.EventSharing.service.InvitationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping(path = "/eventsharing/api/invitation")
public class InvitationController {

    private final InvitationService invitationService;
    @Autowired
    public InvitationController(InvitationService invitationService) {
        this.invitationService = invitationService;
    }

    @PostMapping(path = "/invite/{userId1}/{eventId}")
    public ResponseEntity<String> newInvitation(@PathVariable(value = "userId1") String invitingId,
                                                 @RequestBody List<String> invitedEmail,
                                                 @PathVariable(value = "eventId") String eventId) {
        return invitationService.newInvitation(invitingId, invitedEmail, eventId);

    }

    @GetMapping(path = "/getRecieved/{userId}")
    public ResponseEntity<List<DTOInvitation>> getRecieved(@PathVariable(value = "userId") String userId) {
        return invitationService.recievedInvitation(userId);
    }

    @GetMapping(path = "/getMaded/{userId}")
    public ResponseEntity<List<DTOInvitation>> getMaded(@PathVariable(value = "userId") String userId) {
        return invitationService.madedInvitation(userId);
    }

    @PutMapping(path = "/setState/{invitationId}/{state}")
    public ResponseEntity<String> setInvitationState(
            @PathVariable(value = "invitationId") String invitationId,
            @PathVariable(value = "state") String state) {
        return invitationService.setState(invitationId, state);
    }

    @PutMapping(path = "/setAsRead/{invitationId}")
    public ResponseEntity<String> setAsRead(
            @PathVariable(value = "invitationId") String invitationId) {
        return invitationService.setAsRead(invitationId);
    }

    @DeleteMapping(path = "/delete/{invitationId}")
    public ResponseEntity<String> deleteInvitation(@PathVariable(value = "invitationId") String invitationId) {
        return invitationService.deleteInvitation(invitationId);
    }

}
