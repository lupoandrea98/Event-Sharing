package com.eventsharing.EventSharing.controller;

import com.eventsharing.EventSharing.DTO.DTOUser;
import com.eventsharing.EventSharing.model.User;
import com.eventsharing.EventSharing.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(path = "/eventsharing/api/user")
public class UserController {
    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     *
     * @param user prende come stringa in input l'id dal frontend
     * @return un oggetto che contiene le info richieste:
     *      - Username
     *      - Email
     *      - Immagine del profilo
     */
    @GetMapping(path = "/info/{userId}")
    public ResponseEntity<DTOUser> getUserInfo(@PathVariable(value = "userId") String userId) {
        System.out.println("userid: " + userId);
        ResponseEntity<DTOUser> u = ResponseEntity.ok().body(userService.getUserInfo(userId));
        return u;
    }

    @GetMapping(path = "/username/{userId}")
    public String getUserName(@PathVariable(value = "userId") String userId) {
        //ResponseEntity<String> username = ResponseEntity.ok().body(userService.getUserName(userId));
        //return username;
        return  userService.getUserName(userId);
    }

    /**
     *
     * @param user salva l'utente nel database
     * @return true o false per segnalare la riuscita o il fallimento dell'operazione
     */
    @PostMapping(path = "/signin")
    public ResponseEntity<String> signIn(@RequestBody User user) {
        System.out.println(user);
        return userService.signIn(user);
    }

    @PostMapping(path = "/update")
    public ResponseEntity<String> updateUser(@RequestBody DTOUser user) {
        return userService.updateUser(user);
    }

    @GetMapping(path = "/list/{userId}")
    public ResponseEntity<List<DTOUser>> listOfUser(@PathVariable(value = "userId") String userId) {
        return userService.getListOfUsers(userId);
    }

}
