package com.eventsharing.EventSharing.service;

import com.eventsharing.EventSharing.DTO.DTOEventResponse;
import com.eventsharing.EventSharing.model.Event;
import com.eventsharing.EventSharing.model.Favourite;
import com.eventsharing.EventSharing.model.User;
import com.eventsharing.EventSharing.repository.EventsRepository;
import com.eventsharing.EventSharing.repository.FavouriteRespository;
import com.eventsharing.EventSharing.repository.UsersRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class FavouriteService {

    private final FavouriteRespository favouriteRespository;
    private final EventsRepository eventsRepository;
    private final UsersRepository usersRepository;

    @Autowired
    public FavouriteService(FavouriteRespository favouriteRespository, EventsRepository eventsRepository, UsersRepository usersRepository) {
        this.favouriteRespository = favouriteRespository;
        this.eventsRepository = eventsRepository;
        this.usersRepository = usersRepository;
    }

    @Transactional
    public ResponseEntity<List<DTOEventResponse>> getFavourites(String userId) {
        List<DTOEventResponse> eventsResponse = new ArrayList<>();
        Optional<User> optUser = usersRepository.findById(userId);
        if(optUser.isEmpty()){
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        }
        Optional<List<Favourite>> optFavourites = favouriteRespository.findByUser(optUser.get());
        if(optFavourites.isEmpty())
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        for (Favourite f : optFavourites.get()) {
            DTOEventResponse event = new DTOEventResponse();
            BeanUtils.copyProperties(f.getEvent(), event, "owner", "partecipations", "favourites");
            event.setFavourites(f.getEvent().getFavourites().size());
            event.setPartecipations(f.getEvent().getPartecipations().size());
            event.setOwner(f.getEvent().getOwner().getId());
            eventsResponse.add(event);
        }

        return new ResponseEntity<>(eventsResponse, HttpStatus.OK);
    }

    @Transactional
    public ResponseEntity<String> addToFavourites(String eventId, String userId) {
        Optional<Event> optionalEvent = eventsRepository.findById(Long.parseLong(eventId));
        Optional<User> optionalUser = usersRepository.findById(userId);
        if(optionalUser.isEmpty())
            return new ResponseEntity<>("User not valid", HttpStatus.BAD_REQUEST);
        if(optionalEvent.isEmpty())
            return new ResponseEntity<>("Event not valid", HttpStatus.BAD_REQUEST);
        Optional<Favourite> optionalFavourite = favouriteRespository.findByUserAndEvent(optionalUser.get(), optionalEvent.get());

        if(optionalFavourite.isPresent())
            return new ResponseEntity<>(HttpStatus.CONFLICT);

        favouriteRespository.save(new Favourite(optionalUser.get(), optionalEvent.get()));
        return new ResponseEntity<>("true", HttpStatus.OK);
    }

    @Transactional
    public ResponseEntity<String> removeFavourite(String eventId, String userId) {
        Optional<Event> optionalEvent = eventsRepository.findById(Long.parseLong(eventId));
        Optional<User> optionalUser = usersRepository.findById(userId);
        if(optionalUser.isEmpty())
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        if(optionalEvent.isEmpty())
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);

        Optional<Favourite> optionalFavourite = favouriteRespository.findByUserAndEvent(optionalUser.get(), optionalEvent.get());
        if(optionalFavourite.isEmpty())
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);

        favouriteRespository.delete(optionalFavourite.get());

        return new ResponseEntity<>("true", HttpStatus.OK);
    }

    @Transactional
    public Boolean checkFavourites(String eventId, String userId) {
        Optional<Event> optionalEvent = eventsRepository.findById(Long.parseLong(eventId));
        Optional<User> optionalUser = usersRepository.findById(userId);
        if(optionalUser.isEmpty() || optionalEvent.isEmpty())
            return false;
        Optional<Favourite> optionalFavourite = favouriteRespository.findByUserAndEvent(optionalUser.get(), optionalEvent.get());

        if(optionalFavourite.isPresent())
            return true;

        return false;
    }
}
