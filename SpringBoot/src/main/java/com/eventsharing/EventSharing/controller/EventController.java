package com.eventsharing.EventSharing.controller;

import com.eventsharing.EventSharing.DTO.DTOEventResponse;
import com.eventsharing.EventSharing.DTO.DTOEventRequest;
import com.eventsharing.EventSharing.service.EventService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping(path = "/eventsharing/api/event")
public class EventController {
    private final EventService eventService;

    @Autowired
    public EventController(EventService eventService) {
        this.eventService = eventService;
    }

    @GetMapping(path = "/getAll")
    public ResponseEntity<List<DTOEventResponse>> getEvents() {
        List<DTOEventResponse> temp = eventService.getAllEvent();
        return ResponseEntity.ok().body(temp);
    }

    @GetMapping(path = "/getByZone/{latSx}/{lonSx}/{latDx}/{lonDx}")
    public ResponseEntity<List<DTOEventResponse>> getZoneEvents( @PathVariable(value = "latSx") Double latSx,
                                                                 @PathVariable(value = "lonSx") Double lonSx,
                                                                 @PathVariable(value = "latDx") Double latDx,
                                                                 @PathVariable(value = "lonDx") Double lonDx) {
        return eventService.getZoneEvents(latSx, lonSx, latDx, lonDx);
    }

    @PostMapping(value = "/save")
    public ResponseEntity<String> saveNewEvent(@RequestBody DTOEventRequest event) {
        System.out.println(event);
        return eventService.saveNewEvent(event);
    }

    @PutMapping(value = "/update/{eventId}")
    public ResponseEntity<String> updateEvent(@RequestBody DTOEventRequest newEvent,
                                              @PathVariable(value = "eventId") String eventId) {
        return eventService.updateEvent(newEvent, eventId);
    }


    @DeleteMapping(path = "/delete/{eventId}")
    public ResponseEntity<String> deleteEvent(@PathVariable(value = "eventId") String eventId) {
        return eventService.deleteEvent(eventId);
    }

    @GetMapping(path = "/created/{userId}")
    public ResponseEntity<List<DTOEventResponse>> getEventList(@PathVariable(value = "userId") String userId) {
        return eventService.getCreated(userId);
    }

    @GetMapping(path = "/getEvent/{eventId}")
    public ResponseEntity<DTOEventResponse> getEvent(@PathVariable(value = "eventId") String eventId) {
        return eventService.getEvent(eventId);
    }


}
