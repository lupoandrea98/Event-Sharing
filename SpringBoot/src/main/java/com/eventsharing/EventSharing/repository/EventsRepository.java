package com.eventsharing.EventSharing.repository;

import com.eventsharing.EventSharing.model.Event;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface EventsRepository extends JpaRepository<Event, Long> {

    Optional<Event> findByTitle(String title);
}
