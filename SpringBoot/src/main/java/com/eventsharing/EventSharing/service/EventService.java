package com.eventsharing.EventSharing.service;

import com.eventsharing.EventSharing.DTO.DTOEventResponse;
import com.eventsharing.EventSharing.model.Event;
import com.eventsharing.EventSharing.DTO.DTOEventRequest;
import com.eventsharing.EventSharing.model.User;
import com.eventsharing.EventSharing.repository.*;
import jakarta.transaction.Transactional;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.sql.SQLOutput;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class EventService {
    private final EventsRepository eventsRepository;
    private final UsersRepository usersRepository;
    private final FavouriteRespository favouriteRespository;
    private final PartecipationRepository partecipationRepository;
    private final InvitationRepository invitationRepository;

    @Autowired
    public EventService(EventsRepository eventsRepository,
                        UsersRepository usersRepository,
                        FavouriteRespository favouriteRespository,
                        PartecipationRepository partecipationRepository,
                        InvitationRepository invitationRepository) {
        this.eventsRepository = eventsRepository;
        this.usersRepository = usersRepository;
        this.favouriteRespository = favouriteRespository;
        this.partecipationRepository = partecipationRepository;
        this.invitationRepository = invitationRepository;
    }
    @Transactional
    public List<DTOEventResponse> getAllEvent() {
        List<Event> events = eventsRepository.findAll();
        List<DTOEventResponse> eventResponses = new ArrayList<>();
        for (Event e: events) {
            DTOEventResponse dtoE = new DTOEventResponse();
            BeanUtils.copyProperties(e, dtoE, "owner", "favourites");
            if(e.getOwner()!=null) {
                dtoE.setOwner(e.getOwner().getId());
            }
            eventResponses.add(dtoE);
        }
        return eventResponses;
    }

    @Transactional
    public ResponseEntity<String> saveNewEvent(DTOEventRequest event) {

        Optional<User> owner = usersRepository.findById(event.getOwner());
        if(owner.isEmpty())
            return new ResponseEntity<>("owner not found", HttpStatus.NOT_FOUND);

        Event newEvent = new Event(
                event.getTitle(),
                event.getLatitude(),
                event.getLongitude(),
                event.getAddress(),
                event.getDate(),
                event.getTag(),
                event.getDescription(),
                event.getImage(),
                owner.get(),
                event.getExternalLink(),
                event.getMax_partecipnt()
        );

        Optional<Event> evn = eventsRepository.findByTitle(event.getTitle());
        if(evn.isEmpty()){
            eventsRepository.save(newEvent);
            return new ResponseEntity<>("true", HttpStatus.OK);
        }
        return new ResponseEntity<>("event not saved", HttpStatus.INTERNAL_SERVER_ERROR);
    }
    @Transactional
    public ResponseEntity<String> deleteEvent(String eventId) {
        Long id = Long.parseLong(eventId);
        Optional<Event> optEvent = eventsRepository.findById(id);
        if(optEvent.isEmpty()) {
            return new ResponseEntity<>("Event not found", HttpStatus.BAD_REQUEST);
        }
        favouriteRespository.deleteByEvent(optEvent.get());
        partecipationRepository.deleteByEvent(optEvent.get());
        invitationRepository.deleteByEvent(optEvent.get());

        try {
            eventsRepository.deleteById(id);
            return new ResponseEntity<>("true", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @Transactional
    public ResponseEntity<List<DTOEventResponse>> getCreated(String userId) {
        Optional<User> optUser = usersRepository.findById(userId);
        List<DTOEventResponse> eventsResponse = new ArrayList<>();
        if(optUser.isEmpty())
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        if(!optUser.get().getCreated().isEmpty() && optUser.get().getCreated().size() > 0) {
            for (Event e: optUser.get().getCreated()) {
                DTOEventResponse dtoE = new DTOEventResponse();
                BeanUtils.copyProperties(e, dtoE, "owner");
                if(e.getOwner()!=null) {
                    dtoE.setOwner(e.getOwner().getId());
                }

                eventsResponse.add(dtoE);
            }
            return new ResponseEntity<>(eventsResponse, HttpStatus.OK);
        }
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @Transactional
    public ResponseEntity<String> updateEvent(DTOEventRequest newEvent, String eventId) {
        Optional<Event> optionalEvent = eventsRepository.findById(Long.parseLong(eventId));
        if(optionalEvent.isEmpty())
            return new ResponseEntity<>("Nessun evento trovato",HttpStatus.NOT_FOUND);
        BeanUtils.copyProperties(newEvent, optionalEvent.get());
        return new ResponseEntity<>("true", HttpStatus.OK);

    }
    @Transactional
    public ResponseEntity<List<DTOEventResponse>> getZoneEvents(Double latSx, Double lonSx, Double latDx, Double lonDx) {
        List<Event>events = eventsRepository.findAll();
        List<DTOEventResponse> response = new ArrayList<>();

        for (Event e : events) {
            if(e.getLatitude() == 0 && e.getLongitude() == 0) {
                DTOEventResponse dtoE = new DTOEventResponse();
                BeanUtils.copyProperties(e, dtoE, "owner", "favourites");
                if (e.getOwner() != null) {
                    dtoE.setOwner(e.getOwner().getId());
                }
                response.add(dtoE);
            }
            if (e.getLatitude() <= latSx && e.getLatitude() >= latDx) {
                if (lonSx <= e.getLongitude() && lonDx >= e.getLongitude()) {
                    DTOEventResponse dtoE = new DTOEventResponse();
                    BeanUtils.copyProperties(e, dtoE, "owner", "favourites");
                    if (e.getOwner() != null) {
                        dtoE.setOwner(e.getOwner().getId());
                    }
                    response.add(dtoE);
                }
            }
        }

        return new ResponseEntity<>(response, HttpStatus.OK);

    }
    @Transactional
    public ResponseEntity<DTOEventResponse> getEvent(String eventId) {

        Optional<Event> event = eventsRepository.findById(Long.parseLong(eventId));
        if(event.isEmpty())
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        System.out.println(event.get());
        //BeanUtils.copyProperties(event, dtoE, "owner", "favourites");
        DTOEventResponse dtoE = new DTOEventResponse(event.get().getId(),
                event.get().getTitle(),
                event.get().getLatitude(),
                event.get().getLongitude(),
                event.get().getAddress(),
                event.get().getDate(),
                event.get().getTag(),
                event.get().getDescription(),
                event.get().getImage(),
                event.get().getOwner().getId(),
                event.get().getFavourites().size(),
                event.get().getPartecipations().size(),
                event.get().getQrCode(),
                event.get().getNum_partecipant(),
                event.get().getMax_partecipnt(),
                event.get().getExternalLink()
                );
//        if (event.get().getOwner() != null) {
//            dtoE.setOwner(event.get().getOwner().getId());
//        }
        System.out.println(dtoE);
        return new ResponseEntity<>(dtoE, HttpStatus.OK);
    }
}
