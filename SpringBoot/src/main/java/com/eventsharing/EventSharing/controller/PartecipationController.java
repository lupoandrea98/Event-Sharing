package com.eventsharing.EventSharing.controller;

import com.eventsharing.EventSharing.DTO.DTOEventResponse;
import com.eventsharing.EventSharing.service.PartecipationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(path = "/eventsharing/api/partecipation")
public class PartecipationController {

    private final PartecipationService partecipationService;

    @Autowired
    public PartecipationController(PartecipationService partecipationService) { this.partecipationService = partecipationService; }

    @GetMapping(path = "get/{userId}")
    public ResponseEntity<List<DTOEventResponse>> getFavourites(@PathVariable(value = "userId") String userId) {
        return partecipationService.getPartecipations(userId);
    }

    @PostMapping(path = "/add/{eventId}/{userId}")
    public ResponseEntity<String> addPartecipation(@PathVariable(value = "eventId") String eventId,
                                               @PathVariable(value = "userId") String userId) {
        return partecipationService.addPartecipation(eventId, userId);
    }

    @PutMapping(path = "/remove/{eventId}/{userId}")
    public ResponseEntity<String> removePartecipation(@PathVariable(value = "eventId") String eventId,
                                                  @PathVariable(value = "userId") String userId) {
        return partecipationService.removePartecipation(eventId, userId);
    }

    @GetMapping(path = "/check/{eventId}/{userId}")
    public Boolean checkPartecipation(@PathVariable(value = "eventId") String eventId,
                                  @PathVariable(value = "userId") String userId){
        return partecipationService.checkPartecipation(eventId, userId);
    }

}
