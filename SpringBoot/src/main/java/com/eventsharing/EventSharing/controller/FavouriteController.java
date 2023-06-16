package com.eventsharing.EventSharing.controller;

import com.eventsharing.EventSharing.DTO.DTOEventResponse;
import com.eventsharing.EventSharing.model.Event;
import com.eventsharing.EventSharing.service.FavouriteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(path = "/eventsharing/api/favourite")
public class FavouriteController {

    private final FavouriteService favouriteService;

    @Autowired
    public FavouriteController(FavouriteService favouriteService) {
        this.favouriteService = favouriteService;
    }

    @GetMapping(path = "get/{userId}")
    public ResponseEntity<List<DTOEventResponse>> getFavourites(@PathVariable(value = "userId") String userId) {
        return favouriteService.getFavourites(userId);
    }

    @PostMapping(path = "/add/{eventId}/{userId}")
    public ResponseEntity<String> addFavourite(@PathVariable(value = "eventId") String eventId,
                                               @PathVariable(value = "userId") String userId) {
        System.out.println("addFavourite " + eventId + " " + userId);
        return favouriteService.addToFavourites(eventId, userId);
    }

    @PutMapping(path = "/remove/{eventId}/{userId}")
    public ResponseEntity<String> removeFavourite(@PathVariable(value = "eventId") String eventId,
                                                  @PathVariable(value = "userId") String userId) {
        return favouriteService.removeFavourite(eventId, userId);
    }

    @GetMapping(path = "/check/{eventId}/{userId}")
    public Boolean checkFavourite(@PathVariable(value = "eventId") String eventId,
                                  @PathVariable(value = "userId") String userId){
        System.out.println("check " + eventId + " " + userId);
        return favouriteService.checkFavourites(eventId, userId);
    }
}
