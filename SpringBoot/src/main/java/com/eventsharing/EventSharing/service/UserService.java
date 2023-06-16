package com.eventsharing.EventSharing.service;

import com.eventsharing.EventSharing.DTO.DTOUser;
import com.eventsharing.EventSharing.model.Invitation;
import com.eventsharing.EventSharing.model.User;
import com.eventsharing.EventSharing.repository.InvitationRepository;
import com.eventsharing.EventSharing.repository.UsersRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class UserService {
    private final UsersRepository usersRepository;
    private final InvitationRepository invitationRepository;

    @Autowired
    public UserService(UsersRepository usersRepository, InvitationRepository invitationRepository) {
        this.usersRepository = usersRepository;
        this.invitationRepository = invitationRepository;
    }
    @Transactional
    public ResponseEntity<String> signIn(User user) {
        //Controllo se l'email è già registrata
        Optional<User> optUser = usersRepository.findByEmail(user.getEmail());
        if(optUser.isEmpty()) {
            optUser = usersRepository.findByUsername(user.getUsername());
            if(optUser.isPresent())             //Controllo se l'username è stato preso
                return new ResponseEntity<>("This username is taken", HttpStatus.BAD_REQUEST);
            User u = usersRepository.save(user);
            if(u!=null)
                return new ResponseEntity<>("true", HttpStatus.OK);
        } else {
            return new ResponseEntity<>("This email is taken", HttpStatus.BAD_REQUEST);
        }
        return new ResponseEntity<>("signIn goes wrong", HttpStatus.BAD_REQUEST);
    }
    @Transactional
    public DTOUser getUserInfo(String userId) {
        Optional<User> u = usersRepository.findById(userId);
        Boolean newInvitation = false;
        DTOUser dtoU;
        if(u.isPresent()){
            System.out.println("Utente trovato");
            //Il BeanUtils.copyProperties() non funzionava
            Optional<List<Invitation>> invitations = invitationRepository.findInvitationsByInvitedUser(u.get());
            if(invitations.isPresent()){
                List<Invitation> invitations1 = invitations.get();
                for (int i= 0; i< invitations1.size(); i++ ) {
                    if(invitations1.get(i).getNewInvitation())
                        newInvitation = true;

                    if(invitations1.get(i).getState().equals("Accepted")) {
                        invitations.get().remove(invitations1.get(i));
                        i--;
                    }
                }
                dtoU = new DTOUser(
                        u.get().getId(),
                        u.get().getUsername(),
                        u.get().getEmail(),
                        u.get().getImage(),
                        u.get().getFavourites().size(),
                        u.get().getCreated().size(),
                        u.get().getPartecipations().size(),
                        invitations.get().size(),
                        newInvitation
                );
            } else {
                dtoU = new DTOUser(
                        u.get().getId(),
                        u.get().getUsername(),
                        u.get().getEmail(),
                        u.get().getImage(),
                        u.get().getFavourites().size(),
                        u.get().getCreated().size(),
                        u.get().getPartecipations().size(),
                        0,
                        false
                );
            }

            return dtoU;
        }
        return new DTOUser();
    }
    @Transactional
    public String getUserName(String userId) {
        Optional<User> user = usersRepository.findById(userId);
        if(user.isPresent()) {
            return user.get().getUsername();
        }
        return "";
    }
    @Transactional
    public ResponseEntity<String> updateUser(DTOUser user) {
        Optional<User> us = usersRepository.findById(user.getId());
        if(us.isPresent()) {
            User modified = us.get();

            Optional<User> check = usersRepository.findByUsername(user.getUsername());
            if(check.isPresent() && !check.get().getId().equals(user.getId()))
                return new ResponseEntity<>("username already taken", HttpStatus.CONFLICT);

            if(!modified.getUsername().equals(user.getUsername()) && user.getUsername().length() > 0) {
                modified.setUsername(user.getUsername());
            }

            if(!modified.getEmail().equals(user.getEmail()) && user.getEmail().length() > 0) {
                modified.setEmail(user.getEmail());
            }

            if(!modified.getImage().equals(user.getImage()) && user.getImage().length() > 0) {
                modified.setImage(user.getImage());
            }

            return new ResponseEntity<>("true", HttpStatus.OK);
        } else
            return new ResponseEntity<>("User not present", HttpStatus.BAD_REQUEST);
    }
    @Transactional
    public ResponseEntity<List<DTOUser>> getListOfUsers(String userId) {
        List<DTOUser> response = new ArrayList<>();
        Optional<User> user = usersRepository.findById(userId);
        if(user.isEmpty())
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);

        List<User> users = usersRepository.findAll();

        for (User u: users) {
            if(!u.getId().equals(userId))
                response.add(new DTOUser(
                    u.getId(),
                    u.getUsername(),
                    u.getEmail(),
                    u.getImage(),
                    u.getFavourites().size(),
                    u.getCreated().size(),
                    u.getPartecipations().size(),
                        0,
                        false
                ));
        }

        return new ResponseEntity<>(response, HttpStatus.OK);



    }
}
