package com.eventsharing.EventSharing.repository;

import com.eventsharing.EventSharing.model.Event;
import com.eventsharing.EventSharing.model.Partecipation;
import com.eventsharing.EventSharing.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PartecipationRepository extends JpaRepository<Partecipation, Long> {

    Optional<List<Partecipation>> findByUser(User user);

    Optional<Partecipation> findByUserAndEvent(User user, Event event);

    void deleteByEvent(Event event);
}
