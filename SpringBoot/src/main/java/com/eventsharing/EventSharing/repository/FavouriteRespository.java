package com.eventsharing.EventSharing.repository;

import com.eventsharing.EventSharing.model.Event;
import com.eventsharing.EventSharing.model.Favourite;
import com.eventsharing.EventSharing.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavouriteRespository extends JpaRepository<Favourite, Long> {

    Optional<List<Favourite>> findByUser(User user);

    Optional<List<Favourite>> findByEvent(Event event);

    void deleteByEvent(Event event);
    Optional<Favourite> findByUserAndEvent(User userId, Event eventId);

}
