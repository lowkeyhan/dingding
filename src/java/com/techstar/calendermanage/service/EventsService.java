package com.techstar.calendermanage.service;

import java.util.Date;
import java.util.List;

import org.hibernate.loader.custom.Return;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.techstar.calendermanage.entity.Events;
import com.techstar.calendermanage.jpa.EventsDao;

@Service 
@Transactional
public class EventsService {
	@Autowired
	private  EventsDao eventsDao;
	
	

	public void save(Events events) {
		eventsDao.save(events);
	}
	public Events findById(Long id) {
		return eventsDao.findById(id);
	}
	public  List<Events> findByStarttimeGreaterThanAndStarttimeLessThanAndOperationerid(Date sDate,Date eDate,String userid) {
		return eventsDao.findByStarttimeGreaterThanAndStarttimeLessThanAndOperationerid(sDate, eDate, userid);
	}
	public  List<Events> findByStarttimeGreaterThanAndStarttimeLessThanAndParticipantidLike(Date sDate,Date eDate,String userid) {
		return eventsDao.findByStarttimeGreaterThanAndStarttimeLessThanAndParticipantidLike(sDate, eDate, userid);
	}
}
