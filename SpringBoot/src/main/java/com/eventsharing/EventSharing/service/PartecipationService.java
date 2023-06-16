package com.eventsharing.EventSharing.service;

import com.eventsharing.EventSharing.DTO.DTOEventResponse;
import com.eventsharing.EventSharing.model.Event;
import com.eventsharing.EventSharing.model.Partecipation;
import com.eventsharing.EventSharing.model.User;
import com.eventsharing.EventSharing.repository.EventsRepository;
import com.eventsharing.EventSharing.repository.PartecipationRepository;
import com.eventsharing.EventSharing.repository.UsersRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import javax.swing.text.html.Option;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;

@Service
public class PartecipationService {

    private final PartecipationRepository partecipationRepository;
    private final EventsRepository eventsRepository;
    private final UsersRepository usersRepository;

    @Autowired
    public PartecipationService(PartecipationRepository partecipationRepository, EventsRepository eventsRepository, UsersRepository usersRepository) {
        this.partecipationRepository = partecipationRepository;
        this.eventsRepository = eventsRepository;
        this.usersRepository = usersRepository;
    }

    @Transactional
    public ResponseEntity<List<DTOEventResponse>> getPartecipations(String userId) {
        List<DTOEventResponse> eventsResponse = new ArrayList<>();
        Optional<User> optUser = usersRepository.findById(userId);
        if(optUser.isEmpty())
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);

        Optional<List<Partecipation>> optPartecipations = partecipationRepository.findByUser(optUser.get());
        if(optPartecipations.isEmpty())
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);

        for(Partecipation p : optPartecipations.get()) {
            DTOEventResponse event = new DTOEventResponse();
            BeanUtils.copyProperties(p.getEvent(), event, "owner", "partecipations", "favourites");
            event.setFavourites(p.getEvent().getFavourites().size());
            event.setPartecipations(p.getEvent().getPartecipations().size());
            event.setOwner(p.getEvent().getOwner().getId());
            eventsResponse.add(event);
        }

        return new ResponseEntity<>(eventsResponse, HttpStatus.OK);
    }

    @Transactional
    public ResponseEntity<String> addPartecipation(String eventId, String userId) {
        Optional<Event> optionalEvent = eventsRepository.findById(Long.parseLong(eventId));
        Optional<User> optionalUser = usersRepository.findById(userId);
        if(optionalUser.isEmpty())
            return new ResponseEntity<>("User not valid", HttpStatus.BAD_REQUEST);
        if(optionalEvent.isEmpty())
            return new ResponseEntity<>("Event not valid", HttpStatus.BAD_REQUEST);
        if(optionalEvent.get().getMax_partecipnt() > 0)
            if(optionalEvent.get().getNum_partecipant() == optionalEvent.get().getMax_partecipnt())
                return new ResponseEntity<>("Event full", HttpStatus.BAD_REQUEST);

        Optional<Partecipation> optPartecipation = partecipationRepository.findByUserAndEvent(optionalUser.get(), optionalEvent.get());
        if(optPartecipation.isPresent())
            return new ResponseEntity<>("Partecipation already present", HttpStatus.CONFLICT);

        optionalEvent.get().setNum_partecipant(optionalEvent.get().getNum_partecipant() + 1);
        partecipationRepository.save(new Partecipation(optionalUser.get(), optionalEvent.get()));
        return new ResponseEntity<>("true", HttpStatus.OK);
    }

    @Transactional
    public ResponseEntity<String> removePartecipation(String eventId, String userId) {
        Optional<Event> optionalEvent = eventsRepository.findById(Long.parseLong(eventId));
        Optional<User> optionalUser = usersRepository.findById(userId);
        if(optionalUser.isEmpty())
            return new ResponseEntity<>("User not valid", HttpStatus.BAD_REQUEST);
        if(optionalEvent.isEmpty())
            return new ResponseEntity<>("Event not valid", HttpStatus.BAD_REQUEST);

        Optional<Partecipation> optPartecipation = partecipationRepository.findByUserAndEvent(optionalUser.get(), optionalEvent.get());
        if(optPartecipation.isEmpty())
            return new ResponseEntity<>("Partecipation not present", HttpStatus.CONFLICT);

        partecipationRepository.delete(optPartecipation.get());

        if(optionalEvent.get().getNum_partecipant() > 0 ) {
            optionalEvent.get().setNum_partecipant(optionalEvent.get().getNum_partecipant() - 1);
        } else {
            return new ResponseEntity<>("Number of partecipation conflict", HttpStatus.CONFLICT);
        }

        return new ResponseEntity<>("true", HttpStatus.OK);
    }

    @Transactional
    public Boolean checkPartecipation(String eventId, String userId) {
        Optional<Event> optionalEvent = eventsRepository.findById(Long.parseLong(eventId));
        Optional<User> optionalUser = usersRepository.findById(userId);
        if(optionalUser.isEmpty() || optionalEvent.isEmpty())
            return false;

        Optional<Partecipation> optionalPartecipation = partecipationRepository.findByUserAndEvent(optionalUser.get(), optionalEvent.get());
        if(optionalPartecipation.isPresent())
            return true;

        return false;
    }



}
