package com.eventsharing.EventSharing.service;

import com.eventsharing.EventSharing.DTO.DTOInvitation;
import com.eventsharing.EventSharing.model.Event;
import com.eventsharing.EventSharing.model.Invitation;
import com.eventsharing.EventSharing.model.User;
import com.eventsharing.EventSharing.repository.EventsRepository;
import com.eventsharing.EventSharing.repository.InvitationRepository;
import com.eventsharing.EventSharing.repository.UsersRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class InvitationService {

    private final InvitationRepository invitationRepository;
    private final UsersRepository usersRepository;
    private final EventsRepository eventsRepository;
    private final PartecipationService partecipationService;
    @Autowired
    public InvitationService(InvitationRepository invitationRepository,
                             UsersRepository usersRepository,
                             EventsRepository eventsRepository,
                             PartecipationService partecipationService) {
        this.invitationRepository = invitationRepository;
        this.eventsRepository = eventsRepository;
        this.usersRepository = usersRepository;
        this.partecipationService = partecipationService;
    }
    @Transactional
    public ResponseEntity<String> newInvitation(String invitingId, List<String> invitedEmail, String eventId) {
        Optional<User> invitingUser = usersRepository.findById(invitingId);
        Optional<Event> event = eventsRepository.findById(Long.parseLong(eventId));

        if(invitingUser.isEmpty())
            return new ResponseEntity<>("user cannot make invitation", HttpStatus.BAD_REQUEST);

        if(event.isEmpty())
            return new ResponseEntity<>("event not valid", HttpStatus.BAD_REQUEST);

        if(event.get().getMax_partecipnt() > 0)
            if(event.get().getNum_partecipant() == event.get().getMax_partecipnt())
                return new ResponseEntity<>("event is full", HttpStatus.BAD_REQUEST);

        for (String s : invitedEmail) {
            Optional<User> invitedUser = usersRepository.findByEmail(s);
            if(invitedUser.isEmpty())
                return new ResponseEntity<>("cannot invite " + s, HttpStatus.BAD_REQUEST);
            Optional<Invitation> optionalInvitation = invitationRepository.findInvitationByInvitedUserAndAndInvitingUserAndEvent(invitedUser.get(), invitingUser.get(), event.get());
            if(optionalInvitation.isPresent())
                return new ResponseEntity<>("you have already invited " + s, HttpStatus.BAD_REQUEST);
            Invitation invitation = new Invitation(invitingUser.get(), invitedUser.get(), event.get());
            invitationRepository.save(invitation);
        }
        return new ResponseEntity<>("saved", HttpStatus.OK);
    }
    @Transactional
    public ResponseEntity<List<DTOInvitation>> recievedInvitation(String userId) {
        Optional<User> user = usersRepository.findById(userId);
        List<DTOInvitation> response = new ArrayList<>();
        if(user.isEmpty())
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);

        Optional<List<Invitation>> invitations = invitationRepository.findInvitationsByInvitedUser(user.get());
        if(invitations.isPresent())
            for (Invitation i : invitations.get()) {
                if(!i.getState().equals("Accepted"))
                    response.add(new DTOInvitation(
                            i.getId(),
                            i.getInvitingUser().getImage(),
                            i.getInvitingUser().getUsername(),
                            i.getEvent().getTitle(),
                            i.getEvent().getId(),
                            i.getNewInvitation(),
                            i.getState()
                    ));
            }

        return new ResponseEntity<>(response, HttpStatus.OK);
    }
    @Transactional
    public ResponseEntity<List<DTOInvitation>> madedInvitation(String userId) {
        Optional<User> user = usersRepository.findById(userId);
        List<DTOInvitation> response = new ArrayList<>();
        if(user.isEmpty())
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);

        Optional<List<Invitation>> invitations = invitationRepository.findInvitationsByInvitingUser(user.get());

        for (Invitation i : invitations.get()) {
            response.add(new DTOInvitation(
                    i.getId(),
                    i.getInvitedUser().getImage(),
                    i.getInvitedUser().getUsername(),
                    i.getEvent().getTitle(),
                    i.getEvent().getId(),
                    i.getNewInvitation(),
                    i.getState()
            ));
        }

        return new ResponseEntity<>(response, HttpStatus.OK);

    }
    @Transactional
    public ResponseEntity<String> setState(String invitationId, String state) {
        if(!state.equals("Accepted") && !state.equals("Refused"))
            return new ResponseEntity<>("Invalid State", HttpStatus.BAD_REQUEST);

        Optional<Invitation> invitation = invitationRepository.findById(Long.parseLong(invitationId));

        if(invitation.isEmpty())
            return new ResponseEntity<>("Invitation not valid", HttpStatus.BAD_REQUEST);

        if(state.equals("Accepted")) {
            if(invitation.get().getEvent().getMax_partecipnt() > 0 && invitation.get().getEvent().getNum_partecipant() == invitation.get().getEvent().getMax_partecipnt())
                return new ResponseEntity<>("event is full", HttpStatus.BAD_REQUEST);

            ResponseEntity<String> partecipationResponse = partecipationService.addPartecipation(invitation.get().getEvent().getId().toString(),
                                                  invitation.get().getInvitedUser().getId());
            if(partecipationResponse.getStatusCode() != HttpStatus.OK){
                invitation.get().setState(state);
                return partecipationResponse;
            }
        }

        invitation.get().setState(state);
        return new ResponseEntity<>("ok", HttpStatus.OK);
    }
    @Transactional
    public ResponseEntity<String> setAsRead(String invitationId) {
        Optional<Invitation> invitation = invitationRepository.findById(Long.parseLong(invitationId));
        if(invitation.isEmpty())
            return new ResponseEntity<>("Invitation not valid", HttpStatus.BAD_REQUEST);

        invitation.get().setNewInvitation(false);
        return new ResponseEntity<>("ok", HttpStatus.OK);
    }

    public ResponseEntity<String> deleteInvitation(String invitationId) {
        Optional<Invitation> invitation = invitationRepository.findById(Long.parseLong(invitationId));
        if(invitation.isEmpty())
            return new ResponseEntity<>("invitation not present", HttpStatus.BAD_REQUEST);
        invitationRepository.delete(invitation.get());
        return new ResponseEntity<>("ok", HttpStatus.OK);
    }
}
