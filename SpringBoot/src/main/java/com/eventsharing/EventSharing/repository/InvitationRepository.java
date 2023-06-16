package com.eventsharing.EventSharing.repository;

import com.eventsharing.EventSharing.model.Event;
import com.eventsharing.EventSharing.model.Invitation;
import com.eventsharing.EventSharing.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface InvitationRepository extends JpaRepository<Invitation, Long> {

    Optional<List<Invitation>> findInvitationsByInvitedUser(User invitedUser);

    Optional<List<Invitation>> findInvitationsByInvitingUser(User invitingUser);

    Optional<Invitation> findInvitationByInvitedUserAndAndInvitingUserAndEvent(User invited, User inviting, Event event);

    void deleteByEvent(Event event);
}
